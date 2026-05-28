import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/admin_payment_submission_service.dart';
import '../../data/payment_requirement_service.dart';
import '../../domain/payment_submission.dart';

class AdminFeePaidStudentsScreen extends StatefulWidget {
  final PaymentRequirementDetails fee;

  const AdminFeePaidStudentsScreen({super.key, required this.fee});

  @override
  State<AdminFeePaidStudentsScreen> createState() =>
      _AdminFeePaidStudentsScreenState();
}

class _AdminFeePaidStudentsScreenState
    extends State<AdminFeePaidStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PaymentSubmission> _submissions = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isApplyingDecision = false;

  static const Color _royalBlue = Color(0xFF003DA5);
  static const Color _gold = Color(0xFFFFC107);
  static const Color _mutedText = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final submissions = await AdminPaymentSubmissionService.instance
          .fetchSubmissionsByRequirementId(widget.fee.id);

      if (!mounted) return;

      setState(() {
        _submissions = submissions;
        _isLoading = false;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An error occurred while loading submissions.';
        _isLoading = false;
      });
    }
  }

  List<PaymentSubmission> get _filteredSubmissions {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _submissions;

    return _submissions.where((s) {
      return s.studentName.toLowerCase().contains(query) ||
          s.studentProgram.toLowerCase().contains(query) ||
          s.status.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Positioned(
              bottom: 240,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _buildSearchField(),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Ionicons.arrow_back, color: _royalBlue),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    children: const [
                      TextSpan(
                        text: 'Paid ',
                        style: TextStyle(color: _royalBlue),
                      ),
                      TextSpan(
                        text: 'Students',
                        style: TextStyle(color: _gold),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'export') {
                        _showExportPreviewSheet();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(
                              Ionicons.document_text_outline,
                              size: 18,
                              color: _royalBlue,
                            ),
                            SizedBox(width: 8),
                            const Text(
                              'Export List',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _royalBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Ionicons.ellipsis_vertical,
                      color: _royalBlue,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              widget.fee.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const CircularProgressIndicator(color: _royalBlue, strokeWidth: 3),
            const SizedBox(height: 20),
            const Text(
              'Please Wait',
              style: TextStyle(
                color: _royalBlue,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportPreviewSheet() async {
    final approvedCount = _submissions
        .where((s) => s.status == PaymentSubmissionStatus.approved)
        .length;
    final pendingCount = _submissions
        .where((s) => s.status == PaymentSubmissionStatus.pending)
        .length;
    final rejectedCount = _submissions
        .where((s) => s.status == PaymentSubmissionStatus.rejected)
        .length;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _royalBlue.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _royalBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Ionicons.document_text_outline,
                            size: 18,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Export Record',
                            style: TextStyle(
                              color: _royalBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF5F5F5)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      children: [
                        _buildExportInfoRow('Fee', widget.fee.title),
                        const SizedBox(height: 12),
                        _buildExportInfoRow(
                          'Total',
                          '${_submissions.length} Records',
                        ),
                        const SizedBox(height: 12),
                        _buildExportInfoRow(
                          'Summary',
                          '$approvedCount Approved · $pendingCount Pending · $rejectedCount Rejected',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _saveExcelToDevice();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Ionicons.download_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save to Device',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _exportToExcel();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _royalBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Ionicons.share_social_outline,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Share Excel',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExportInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _royalBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<int>?> _generateExcelBytes() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add Header Info
    sheet.appendRow([TextCellValue('VOUCH PAYMENT REPORT')]);
    sheet.appendRow([
      TextCellValue('Fee Title:'),
      TextCellValue(widget.fee.title),
    ]);
    sheet.appendRow([
      TextCellValue('Amount:'),
      TextCellValue('₱${widget.fee.amount.toStringAsFixed(2)}'),
    ]);
    sheet.appendRow([
      TextCellValue('Generated:'),
      TextCellValue(DateTime.now().toString().split('.')[0]),
    ]);
    sheet.appendRow([TextCellValue('')]);

    // Table Header
    sheet.appendRow([
      TextCellValue('Student Name'),
      TextCellValue('Program'),
      TextCellValue('Amount Paid'),
      TextCellValue('Status'),
      TextCellValue('Payment Method'),
      TextCellValue('Time'),
    ]);

    for (final s in _submissions) {
      sheet.appendRow([
        TextCellValue(s.studentName),
        TextCellValue(s.studentProgram),
        TextCellValue('₱${s.amount}'),
        TextCellValue(s.status),
        TextCellValue(s.paymentMethod),
        TextCellValue(s.submittedAt.isNotEmpty ? s.submittedAt : s.timeAgo),
      ]);
    }

    return excel.save();
  }

  Future<void> _exportToExcel() async {
    _showLoadingDialog('Generating Excel report...');

    try {
      final fileBytes = await _generateExcelBytes();
      if (fileBytes == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final directory = await getTemporaryDirectory();
      final sanitizedFeeTitle = widget.fee.title.replaceAll(
        RegExp(r'[^\w\s-]'),
        '',
      );
      final fileName = '${sanitizedFeeTitle}_Payment_Report.xlsx';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      if (mounted) Navigator.pop(context);

      await Share.shareXFiles([
        XFile(file.path),
      ], subject: '${widget.fee.title} Payment Report');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  Future<void> _saveExcelToDevice() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }

    _showLoadingDialog('Saving to device...');

    try {
      final fileBytes = await _generateExcelBytes();
      if (fileBytes == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final sanitizedFeeTitle = widget.fee.title.replaceAll(
        RegExp(r'[^\w\s-]'),
        '',
      );
      final fileName =
          '${sanitizedFeeTitle}_Payment_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Documents');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        if (mounted) Navigator.pop(context);
        throw Exception('Could not access storage directory');
      }

      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      if (mounted) Navigator.pop(context);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved to Documents folder.'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search student or status',
        hintStyle: const TextStyle(color: _mutedText, fontSize: 13),
        prefixIcon: const Icon(Ionicons.search, color: _royalBlue, size: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _royalBlue.withOpacity(0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _royalBlue.withOpacity(0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _royalBlue, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _royalBlue));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Ionicons.alert_circle_outline,
                color: Colors.red,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSubmissions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final submissions = _filteredSubmissions;

    if (submissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Ionicons.people_outline,
              color: _royalBlue.withOpacity(0.3),
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'No students have paid this fee yet.',
              style: TextStyle(color: _mutedText, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: submissions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildSubmissionCard(submissions[index]);
      },
    );
  }

  Widget _buildSubmissionCard(PaymentSubmission submission) {
    final statusColor = _getStatusColor(submission.status);
    final isPending = submission.status == PaymentSubmissionStatus.pending;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _royalBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _royalBlue.withOpacity(0.1),
                child: Text(
                  submission.avatarText,
                  style: const TextStyle(
                    color: _royalBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.studentName,
                      style: const TextStyle(
                        color: _royalBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      submission.studentProgram,
                      style: const TextStyle(color: _mutedText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  submission.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₱${submission.amount}',
                style: const TextStyle(
                  color: _royalBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                submission.timeAgo,
                style: const TextStyle(color: _mutedText, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _royalBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Ionicons.document_text_outline,
                  color: _mutedText,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    submission.proofFile,
                    style: const TextStyle(color: _mutedText, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (submission.receiptAssetPath.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showReceiptPreview(submission),
                    child: const Text(
                      'View Receipt',
                      style: TextStyle(
                        color: _royalBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isApplyingDecision
                        ? null
                        : () => _handleDecision(submission, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isApplyingDecision
                        ? null
                        : () => _handleDecision(submission, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case PaymentSubmissionStatus.approved:
        return Colors.green;
      case PaymentSubmissionStatus.rejected:
        return Colors.red;
      default:
        return _royalBlue;
    }
  }

  void _showReceiptPreview(PaymentSubmission submission) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Receipt Preview',
                    style: TextStyle(
                      color: _royalBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Ionicons.close, color: _royalBlue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF3F4F6),
                      child: submission.receiptAssetPath.startsWith('http')
                          ? Image.network(
                              submission.receiptAssetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Text('Error loading image'),
                                  ),
                            )
                          : Image.asset(
                              submission.receiptAssetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Text('Sample image not found'),
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDecision(
    PaymentSubmission submission,
    bool approve,
  ) async {
    String? note;
    if (!approve) {
      note = await _showRejectionNoteDialog();
      if (note == null) return;
    }

    setState(() => _isApplyingDecision = true);
    try {
      await AdminPaymentSubmissionService.instance.updateSubmissionStatus(
        transactionId: int.parse(submission.id),
        isApproved: approve,
        reviewNote: note,
      );
      await _loadSubmissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Payment approved' : 'Payment rejected'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isApplyingDecision = false);
    }
  }

  Future<String?> _showRejectionNoteDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejection Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Reason for rejection'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
