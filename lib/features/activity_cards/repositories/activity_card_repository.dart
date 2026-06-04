import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_card_models.dart';

class ActivityCardRepository {
  final SupabaseClient _client;

  ActivityCardRepository(this._client);

  Future<List<ActivityCard>> getStudentActivityCards(String studentId) async {
    // 1. Get active term
    final termResponse = await _client
        .from('academic_terms')
        .select()
        .eq('is_active', true)
        .maybeSingle();
    
    if (termResponse == null) return [];
    
    final termId = termResponse['id'];
    final academicYear = termResponse['academic_year'];
    final semester = termResponse['semester'];

    // 2. Get student's organizations
    final orgMembersResponse = await _client
        .from('organization_members')
        .select('organization_id, organizations(*)')
        .eq('user_id', studentId)
        .eq('status', 'active');
    
    final List orgMembers = orgMembersResponse as List;
    if (orgMembers.isEmpty) return [];

    // Collect all unique scope IDs
    final Set<String> scopeIds = {};
    for (var member in orgMembers) {
      final org = member['organizations'];
      final orgType = org['type'];
      String? scopeId = org['campus_id'];
      if (orgType == 'faculty-based') {
        scopeId = org['faculty_id'];
      } else if (orgType == 'program-based') {
        scopeId = org['program_id'];
      }
      if (scopeId != null) scopeIds.add(scopeId);
    }

    if (scopeIds.isEmpty) return [];

    // 3, 4, 5. Fetch all data in bulk parallel requests
    final List<Future<dynamic>> futures = [
      _client
          .from('events')
          .select('''
            *,
            attendance:student_attendance!left (
              status,
              actual_time_in,
              actual_time_out
            )
          ''')
          .filter('scope_id', 'in', scopeIds.toList())
          .eq('academic_term_id', termId)
          .eq('attendance.student_id', studentId),
      _client
          .from('fees')
          .select('''
            *,
            payments:student_payments!left (
              status,
              amount_paid,
              paid_at,
              reference_number
            )
          ''')
          .filter('scope_id', 'in', scopeIds.toList())
          .eq('academic_term_id', termId)
          .eq('payments.student_id', studentId),
      _client
          .from('activity_card_clearance_requests')
          .select('''
            *,
            signatures:activity_card_clearance_signatures (
              *,
              role:roles (name)
            )
          ''')
          .eq('student_id', studentId)
          .filter('scope_id', 'in', scopeIds.toList())
          .eq('academic_term_id', termId)
    ];

    final results = await Future.wait(futures);

    final allEvents = results[0] as List;
    final allFees = results[1] as List;
    final allClearanceRequests = results[2] as List;

    List<ActivityCard> cards = [];

    for (var member in orgMembers) {
      final org = member['organizations'];
      final orgId = org['id'];
      final orgName = org['name'];
      final orgLogo = org['logo_url'];
      final orgType = org['type'];

      // Determine scope for events/fees
      String? scopeId = org['campus_id'];
      if (orgType == 'faculty-based') {
        scopeId = org['faculty_id'];
      } else if (orgType == 'program-based') {
        scopeId = org['program_id'];
      }

      if (scopeId == null) continue;

      // Filter bulk results for this organization's scope
      final eventsResponse = allEvents.where((e) => e['scope_id'] == scopeId).toList();
      final feesResponse = allFees.where((f) => f['scope_id'] == scopeId).toList();
      final clearanceResponse = allClearanceRequests.where((c) => c['scope_id'] == scopeId).firstOrNull;

      // Map to models
      final List<ActivityCardEvent> events = eventsResponse.map((e) {
        final attendance = (e['attendance'] as List).firstOrNull;
        return ActivityCardEvent(
          id: e['id'],
          eventId: e['id'],
          title: e['name'],
          category: e['scope_type'],
          date: DateTime.parse(e['event_date']),
          attendanceStatus: _mapAttendanceStatus(attendance?['status']),
          completedAt: attendance?['actual_time_out'] != null 
            ? DateTime.parse(attendance!['actual_time_out']) 
            : null,
        );
      }).toList();

      final List<ActivityCardFee> fees = feesResponse.map((f) {
        final payment = (f['payments'] as List).where((p) => p['status'] == 'Paid').firstOrNull;
        return ActivityCardFee(
          id: f['id'],
          feeId: f['id'],
          title: f['name'],
          category: f['scope_type'],
          amount: (f['amount'] as num).toDouble(),
          isPaid: payment != null,
          paidAt: payment?['paid_at'] != null ? DateTime.parse(payment!['paid_at']) : null,
          referenceNumber: payment?['reference_number'],
        );
      }).toList();

      final List<ActivityCardSignature> signatures = [];
      if (clearanceResponse != null && clearanceResponse['signatures'] != null) {
        for (var i = 0; i < (clearanceResponse['signatures'] as List).length; i++) {
          final s = clearanceResponse['signatures'][i];
          signatures.add(ActivityCardSignature(
            id: s['id'],
            roleName: s['role']['name'],
            signedByUserId: s['signed_by_user_id'],
            status: _mapSignatureStatus(s['status']),
            signedAt: s['signed_at'] != null ? DateTime.parse(s['signed_at']) : null,
            rejectionReason: s['remarks'],
            order: i,
          ));
        }
      }

      // Calculate completion
      final completedEvents = events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length;
      final paidFees = fees.where((f) => f.isPaid).length;
      final totalItems = events.length + fees.length;
      final completionPercentage = totalItems > 0 
        ? (completedEvents + paidFees) / totalItems 
        : 0.0;

      cards.add(ActivityCard(
        id: clearanceResponse?['id'] ?? 'temp-$orgId',
        studentId: studentId,
        organizationId: orgId,
        organizationName: orgName,
        organizationLogo: orgLogo,
        organizationType: orgType,
        academicYear: academicYear,
        semester: semester,
        status: _mapClearanceStatus(clearanceResponse?['status']),
        completionPercentage: completionPercentage,
        events: events,
        fees: fees,
        signatures: signatures,
      ));
    }

    return cards;
  }

  AttendanceStatus _mapAttendanceStatus(String? status) {
    switch (status) {
      case 'Present': return AttendanceStatus.completed;
      case 'Absent': return AttendanceStatus.absent;
      case 'Late': return AttendanceStatus.completed;
      case 'Excused': return AttendanceStatus.excused;
      case 'Pending': return AttendanceStatus.pending;
      default: return AttendanceStatus.pending;
    }
  }

  SignatureStatus _mapSignatureStatus(String? status) {
    switch (status) {
      case 'Signed': return SignatureStatus.signed;
      case 'Rejected': return SignatureStatus.rejected;
      case 'Pending': return SignatureStatus.pending;
      default: return SignatureStatus.pending;
    }
  }

  ActivityCardStatus _mapClearanceStatus(String? status) {
    switch (status) {
      case 'Cleared': return ActivityCardStatus.cleared;
      case 'Rejected': return ActivityCardStatus.rejected;
      case 'Pending': return ActivityCardStatus.pending;
      default: return ActivityCardStatus.pending;
    }
  }
}
