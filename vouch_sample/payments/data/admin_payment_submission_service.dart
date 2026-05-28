import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/supabase_auth_service.dart';
import '../domain/payment_submission.dart';

class AdminPaymentSubmissionService {
  AdminPaymentSubmissionService._();

  static final AdminPaymentSubmissionService instance =
      AdminPaymentSubmissionService._();

  static const String _transactionsTable = 'student_transactions';
  static const String _requirementsTable = 'payment_requirements';
  static const String _studentsTable = 'students';
  static const String _adminsTable = 'admins';

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PaymentSubmission>> fetchSubmissionsByRequirementId(
    int requirementId,
  ) async {
    final adminId = await _resolveCurrentAdminId();
    final transactions = await _fetchTransactionsByRequirementId(requirementId);

    if (transactions.isEmpty) {
      return const <PaymentSubmission>[];
    }

    final requirementResponse = await _client
        .from(_requirementsTable)
        .select('id, title, amount')
        .eq('id', requirementId)
        .eq('admin_id', adminId)
        .maybeSingle();

    if (requirementResponse == null) {
      return const <PaymentSubmission>[];
    }

    final requirement = Map<String, dynamic>.from(requirementResponse);

    final studentIds = transactions
        .map((transaction) => transaction.studentId)
        .where((studentId) => studentId.isNotEmpty)
        .toSet()
        .toList();

    final studentsById = await _fetchStudentsById(studentIds);

    final submissions = <PaymentSubmission>[];

    for (final transaction in transactions) {
      final student = studentsById[transaction.studentId];

      final studentName = _resolveStudentName(
        student,
        fallback: transaction.studentId,
      );
      final studentProgram = _readString(student?['program']);
      final feeTitle = _readString(requirement['title']);
      final amount = _readDouble(requirement['amount']);

      submissions.add(
        PaymentSubmission(
          id: transaction.id.toString(),
          studentName: studentName,
          studentProgram: studentProgram.isNotEmpty ? studentProgram : 'N/A',
          courseName: feeTitle.isNotEmpty
              ? feeTitle
              : 'Fee #${transaction.requirementId}',
          amount: amount.toStringAsFixed(2),
          paymentMethod: transaction.paymentMethod,
          timeAgo: _formatTimeAgo(transaction.createdAt),
          submittedAt: _formatExactDateTime(transaction.createdAt),
          avatarText: _buildAvatarText(studentName),
          proofFile: _buildProofLabel(transaction),
          receiptAssetPath: transaction.proofPhotoUrl,
          status: _mapStatus(transaction.status),
          rejectionNote: transaction.reviewNote,
        ),
      );
    }

    return submissions;
  }

  Future<List<_TransactionRow>> _fetchTransactionsByRequirementId(
    int requirementId,
  ) async {
    try {
      final response = await _client
          .from(_transactionsTable)
          .select(
            'id, student_id, requirement_id, reference_number, proof_photo_url, payment_method, status, created_at, rejection_note',
          )
          .eq('requirement_id', requirementId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map(
            (data) => _TransactionRow.fromMap(
              data,
              includeCreatedAt: true,
              includeReviewNote: true,
              includePaymentMethod: true,
            ),
          )
          .toList();
    } on PostgrestException catch (error) {
      final isMissingCreatedAt = _isMissingColumnError(error, 'created_at');
      final isMissingReviewNote = _isMissingColumnError(
        error,
        'rejection_note',
      );
      final isMissingPaymentMethod = _isMissingColumnError(
        error,
        'payment_method',
      );

      if (!isMissingCreatedAt &&
          !isMissingReviewNote &&
          !isMissingPaymentMethod) {
        rethrow;
      }

      // Fallback selection based on what might be missing
      final selectColumns = [
        'id',
        'student_id',
        'requirement_id',
        'reference_number',
        'proof_photo_url',
        'status',
      ];
      if (!isMissingPaymentMethod) selectColumns.add('payment_method');
      if (!isMissingCreatedAt) selectColumns.add('created_at');
      if (!isMissingReviewNote) selectColumns.add('rejection_note');

      final fallbackResponse = await _client
          .from(_transactionsTable)
          .select(selectColumns.join(', '))
          .eq('requirement_id', requirementId)
          .order(isMissingCreatedAt ? 'id' : 'created_at', ascending: false);

      return List<Map<String, dynamic>>.from(fallbackResponse)
          .map(
            (data) => _TransactionRow.fromMap(
              data,
              includeCreatedAt: !isMissingCreatedAt,
              includeReviewNote: !isMissingReviewNote,
              includePaymentMethod: !isMissingPaymentMethod,
            ),
          )
          .toList();
    }
  }

  Future<void> updateSubmissionStatus({
    required int transactionId,
    required bool isApproved,
    String? reviewNote,
  }) async {
    if (transactionId <= 0) {
      throw ArgumentError('Invalid submission id.');
    }

    final normalizedReviewNote = reviewNote?.trim() ?? '';
    if (!isApproved && normalizedReviewNote.isEmpty) {
      throw ArgumentError('Please provide a rejection note.');
    }

    final adminId = await _resolveCurrentAdminId();
    final nextStatus = isApproved ? 'approved' : 'rejected';

    try {
      final updated = await _client
          .from(_transactionsTable)
          .update({
            'status': nextStatus,
            'reviewed_by': adminId,
            'rejection_note': isApproved ? null : normalizedReviewNote,
          })
          .eq('id', transactionId)
          .select('id')
          .maybeSingle();

      if (updated == null) {
        throw StateError('Submission record no longer exists.');
      }
    } on PostgrestException catch (error) {
      if (!_isMissingColumnError(error, 'rejection_note')) {
        rethrow;
      }

      if (!isApproved) {
        throw StateError(
          'Rejection note could not be saved because student_transactions.rejection_note is missing. Add a rejection_note text column and try again.',
        );
      }

      final updated = await _client
          .from(_transactionsTable)
          .update({'status': nextStatus, 'reviewed_by': adminId})
          .eq('id', transactionId)
          .select('id')
          .maybeSingle();

      if (updated == null) {
        throw StateError('Submission record no longer exists.');
      }
    }
  }

  Future<List<PaymentSubmission>> fetchSubmissionsForCurrentAdmin() async {
    final adminId = await _resolveCurrentAdminId();
    final transactions = await _fetchTransactions();

    if (transactions.isEmpty) {
      return const <PaymentSubmission>[];
    }

    final requirementIds = transactions
        .map((transaction) => transaction.requirementId)
        .where((id) => id > 0)
        .toSet()
        .toList();

    final requirementsById = await _fetchRequirementsById(
      requirementIds,
      adminId: adminId,
    );

    if (requirementsById.isEmpty) {
      return const <PaymentSubmission>[];
    }

    final studentIds = transactions
        .map((transaction) => transaction.studentId)
        .where((studentId) => studentId.isNotEmpty)
        .toSet()
        .toList();

    final studentsById = await _fetchStudentsById(studentIds);

    final submissions = <PaymentSubmission>[];

    for (final transaction in transactions) {
      final requirement = requirementsById[transaction.requirementId];
      if (requirement == null) {
        continue;
      }

      final student = studentsById[transaction.studentId];

      final studentName = _resolveStudentName(
        student,
        fallback: transaction.studentId,
      );
      final studentProgram = _readString(student?['program']);
      final feeTitle = _readString(requirement['title']);
      final amount = _readDouble(requirement['amount']);

      submissions.add(
        PaymentSubmission(
          id: transaction.id.toString(),
          studentName: studentName,
          studentProgram: studentProgram.isNotEmpty ? studentProgram : 'N/A',
          courseName: feeTitle.isNotEmpty
              ? feeTitle
              : 'Fee #${transaction.requirementId}',
          amount: amount.toStringAsFixed(2),
          paymentMethod: transaction.paymentMethod,
          timeAgo: _formatTimeAgo(transaction.createdAt),
          submittedAt: _formatExactDateTime(transaction.createdAt),
          avatarText: _buildAvatarText(studentName),
          proofFile: _buildProofLabel(transaction),
          receiptAssetPath: transaction.proofPhotoUrl,
          status: _mapStatus(transaction.status),
          rejectionNote: transaction.reviewNote,
        ),
      );
    }

    return submissions;
  }

  Future<List<_TransactionRow>> _fetchTransactions() async {
    try {
      final response = await _client
          .from(_transactionsTable)
          .select(
            'id, student_id, requirement_id, reference_number, proof_photo_url, payment_method, status, created_at, rejection_note',
          )
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map(
            (data) => _TransactionRow.fromMap(
              data,
              includeCreatedAt: true,
              includeReviewNote: true,
              includePaymentMethod: true,
            ),
          )
          .toList();
    } on PostgrestException catch (error) {
      final isMissingCreatedAt = _isMissingColumnError(error, 'created_at');
      final isMissingReviewNote = _isMissingColumnError(
        error,
        'rejection_note',
      );
      final isMissingPaymentMethod = _isMissingColumnError(
        error,
        'payment_method',
      );

      if (!isMissingCreatedAt &&
          !isMissingReviewNote &&
          !isMissingPaymentMethod) {
        rethrow;
      }

      // Fallback selection based on what might be missing
      final selectColumns = [
        'id',
        'student_id',
        'requirement_id',
        'reference_number',
        'proof_photo_url',
        'status',
      ];
      if (!isMissingPaymentMethod) selectColumns.add('payment_method');
      if (!isMissingCreatedAt) selectColumns.add('created_at');
      if (!isMissingReviewNote) selectColumns.add('rejection_note');

      final fallbackResponse = await _client
          .from(_transactionsTable)
          .select(selectColumns.join(', '))
          .order(isMissingCreatedAt ? 'id' : 'created_at', ascending: false);

      return List<Map<String, dynamic>>.from(fallbackResponse)
          .map(
            (data) => _TransactionRow.fromMap(
              data,
              includeCreatedAt: !isMissingCreatedAt,
              includeReviewNote: !isMissingReviewNote,
              includePaymentMethod: !isMissingPaymentMethod,
            ),
          )
          .toList();
    }
  }

  Future<Map<int, Map<String, dynamic>>> _fetchRequirementsById(
    List<int> requirementIds, {
    required int adminId,
  }) async {
    if (requirementIds.isEmpty) {
      return const <int, Map<String, dynamic>>{};
    }

    final response = await _client
        .from(_requirementsTable)
        .select('id, title, amount')
        .eq('admin_id', adminId)
        .inFilter('id', requirementIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final mapped = <int, Map<String, dynamic>>{};

    for (final row in rows) {
      final id = _readInt(row['id']);
      if (id <= 0) {
        continue;
      }

      mapped[id] = row;
    }

    return mapped;
  }

  Future<Map<String, Map<String, dynamic>>> _fetchStudentsById(
    List<String> studentIds,
  ) async {
    if (studentIds.isEmpty) {
      return const <String, Map<String, dynamic>>{};
    }

    final response = await _client
        .from(_studentsTable)
        .select('student_id, full_name, program')
        .inFilter('student_id', studentIds);

    final rows = List<Map<String, dynamic>>.from(response);
    final mapped = <String, Map<String, dynamic>>{};

    for (final row in rows) {
      final studentId = _readString(row['student_id']);
      if (studentId.isEmpty) {
        continue;
      }

      mapped[studentId] = row;
    }

    return mapped;
  }

  Future<int> _resolveCurrentAdminId() async {
    final email = SupabaseAuthService.currentUser?.email?.trim();
    if (email == null || email.isEmpty) {
      throw StateError('No authenticated admin found.');
    }

    final admin = await _client
        .from(_adminsTable)
        .select('id')
        .ilike('email', email)
        .maybeSingle();

    final adminId = _readInt(admin?['id']);
    if (adminId > 0) {
      return adminId;
    }

    throw StateError('Admin account not found.');
  }

  String _mapStatus(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase();

    if (normalized == 'approved' ||
        normalized == 'paid' ||
        normalized == 'verified') {
      return PaymentSubmissionStatus.approved;
    }

    if (normalized == 'rejected' || normalized == 'declined') {
      return PaymentSubmissionStatus.rejected;
    }

    return PaymentSubmissionStatus.pending;
  }

  String _resolveStudentName(
    Map<String, dynamic>? student, {
    required String fallback,
  }) {
    final fullName = _readString(student?['full_name']);
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final normalizedFallback = fallback.trim();
    return normalizedFallback.isNotEmpty ? normalizedFallback : 'Student';
  }

  String _buildAvatarText(String name) {
    final tokens = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.length >= 2) {
      return '${tokens[0][0]}${tokens[1][0]}'.toUpperCase();
    }

    if (tokens.isEmpty) {
      return 'ST';
    }

    final firstToken = tokens.first;
    if (firstToken.length >= 2) {
      return firstToken.substring(0, 2).toUpperCase();
    }

    return firstToken[0].toUpperCase();
  }

  String _buildProofLabel(_TransactionRow transaction) {
    final reference = transaction.referenceNumber.trim();
    if (reference.isNotEmpty) {
      return 'Ref: $reference';
    }

    final fileName = _extractFileNameFromUrl(transaction.proofPhotoUrl);
    if (fileName.isNotEmpty) {
      return fileName;
    }

    return 'Uploaded proof';
  }

  String _extractFileNameFromUrl(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(url);
    final segments = uri?.pathSegments ?? const <String>[];

    if (segments.isNotEmpty) {
      return Uri.decodeComponent(segments.last);
    }

    return '';
  }

  String _formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Recently';
    }

    final duration = DateTime.now().difference(createdAt.toLocal());

    if (duration.isNegative || duration.inSeconds < 60) {
      return 'Just now';
    }

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    }

    if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    }

    if (duration.inDays < 7) {
      return '${duration.inDays}d ago';
    }

    if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      return '${weeks <= 0 ? 1 : weeks}w ago';
    }

    if (duration.inDays < 365) {
      final months = (duration.inDays / 30).floor();
      return '${months <= 0 ? 1 : months}mo ago';
    }

    final years = (duration.inDays / 365).floor();
    return '${years <= 0 ? 1 : years}y ago';
  }

  String _formatExactDateTime(DateTime? createdAt) {
    if (createdAt == null) {
      return '';
    }

    final local = createdAt.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');

    return '${local.year}-$month-$day $hour:$minute:$second';
  }

  bool _isMissingColumnError(PostgrestException error, String columnName) {
    final details = '${error.details ?? ''}'.toLowerCase();
    final hint = (error.hint ?? '').toLowerCase();
    final message = error.message.toLowerCase();
    final lookup = columnName.trim().toLowerCase();
    final combined = '$message $details $hint';

    return combined.contains('column') && combined.contains(lookup);
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  static double _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return null;
      }

      return DateTime.tryParse(normalized);
    }

    return null;
  }
}

class _TransactionRow {
  final int id;
  final String studentId;
  final int requirementId;
  final String referenceNumber;
  final String proofPhotoUrl;
  final String paymentMethod;
  final String status;
  final String reviewNote;
  final DateTime? createdAt;

  const _TransactionRow({
    required this.id,
    required this.studentId,
    required this.requirementId,
    required this.referenceNumber,
    required this.proofPhotoUrl,
    required this.paymentMethod,
    required this.status,
    required this.reviewNote,
    required this.createdAt,
  });

  factory _TransactionRow.fromMap(
    Map<String, dynamic> data, {
    bool includeCreatedAt = true,
    bool includeReviewNote = true,
    bool includePaymentMethod = true,
  }) {
    return _TransactionRow(
      id: AdminPaymentSubmissionService._readInt(data['id']),
      studentId: AdminPaymentSubmissionService._readString(data['student_id']),
      requirementId: AdminPaymentSubmissionService._readInt(
        data['requirement_id'],
      ),
      referenceNumber: AdminPaymentSubmissionService._readString(
        data['reference_number'],
      ),
      proofPhotoUrl: AdminPaymentSubmissionService._readString(
        data['proof_photo_url'],
      ),
      paymentMethod: includePaymentMethod
          ? AdminPaymentSubmissionService._readString(data['payment_method'])
          : 'GCash',
      status: AdminPaymentSubmissionService._readString(data['status']),
      reviewNote: includeReviewNote ? _readRejectionNote(data) : '',
      createdAt: includeCreatedAt
          ? AdminPaymentSubmissionService._parseDateTime(data['created_at'])
          : null,
    );
  }

  static String _readRejectionNote(Map<String, dynamic> data) {
    final rejectionNote = AdminPaymentSubmissionService._readString(
      data['rejection_note'],
    );
    if (rejectionNote.isNotEmpty) {
      return rejectionNote;
    }

    return AdminPaymentSubmissionService._readString(data['review_note']);
  }
}
