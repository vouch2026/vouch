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
    
    List<ActivityCard> cards = [];

    for (var member in orgMembersResponse as List) {
      final org = member['organizations'];
      final orgId = org['id'];
      final orgName = org['name'];
      final orgLogo = org['logo_url'];
      final orgType = org['type'];

      // Determine scope for events/fees
      String scopeType = 'Institutional';
      String? scopeId = org['campus_id'];
      if (orgType == 'faculty-based') {
        scopeType = 'Faculty';
        scopeId = org['faculty_id'];
      } else if (orgType == 'program-based') {
        scopeType = 'Program';
        scopeId = org['program_id'];
      }

      if (scopeId == null) continue;

      // 3. Fetch events and attendance
      final eventsResponse = await _client
          .from('events')
          .select('''
            *,
            attendance:student_attendance!left (
              status,
              actual_time_in,
              actual_time_out
            )
          ''')
          .eq('scope_type', scopeType)
          .eq('scope_id', scopeId)
          .eq('academic_term_id', termId)
          .eq('attendance.student_id', studentId);

      // 4. Fetch fees and payments
      final feesResponse = await _client
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
          .eq('scope_type', scopeType)
          .eq('scope_id', scopeId)
          .eq('academic_term_id', termId)
          .eq('payments.student_id', studentId);

      // 5. Fetch clearance request and signatures
      final clearanceResponse = await _client
          .from('activity_card_clearance_requests')
          .select('''
            *,
            signatures:activity_card_clearance_signatures (
              *,
              role:roles (name)
            )
          ''')
          .eq('student_id', studentId)
          .eq('scope_type', scopeType)
          .eq('scope_id', scopeId)
          .eq('academic_term_id', termId)
          .maybeSingle();

      // Map to models
      final List<ActivityCardEvent> events = (eventsResponse as List).map((e) {
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

      final List<ActivityCardFee> fees = (feesResponse as List).map((f) {
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
        id: clearanceResponse?['id'] ?? 'temp-${orgId}',
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
