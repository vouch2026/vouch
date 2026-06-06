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
        .limit(1)
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

  Future<List<ActivityCard>> getOrganizationActivityCards(String organizationId) async {
    // 1. Get active term
    final termResponse = await _client
        .from('academic_terms')
        .select()
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();
    
    if (termResponse == null) return [];
    final termId = termResponse['id'];
    final academicYear = termResponse['academic_year'];
    final semester = termResponse['semester'];

    // 2. Get organization info and its scope
    final orgResponse = await _client
        .from('organizations')
        .select()
        .eq('id', organizationId)
        .single();
    
    final orgType = orgResponse['type'];
    final orgName = orgResponse['name'];
    final orgLogo = orgResponse['logo_url'];
    String? scopeId = orgResponse['campus_id'];
    if (orgType == 'faculty-based') {
      scopeId = orgResponse['faculty_id'];
    } else if (orgType == 'program-based') {
      scopeId = orgResponse['program_id'];
    }

    if (scopeId == null) return [];

    // 3. Get all students (members) of this organization
    // We join with users to get their names and program names
    final membersResponse = await _client
        .from('organization_members')
        .select('''
          user_id,
          student:users (
            id,
            first_name,
            last_name,
            student_id_number,
            program:programs!users_program_id_fkey (name)
          )
        ''')
        .eq('organization_id', organizationId)
        .eq('status', 'active');
    
    final List members = membersResponse as List;
    if (members.isEmpty) return [];

    final studentIds = members.map((m) => m['user_id'] as String).toList();

    // 4. Get events and fees for this scope
    final eventsResponse = await _client
        .from('events')
        .select('id, name, scope_type, event_date')
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId);
    
    final feesResponse = await _client
        .from('fees')
        .select('id, name, scope_type, amount')
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId);

    // 5. Get all attendance, payments, and clearance requests for these students in bulk
    final List<Future<dynamic>> futures = [
      _client
          .from('student_attendance')
          .select('student_id, event_id, status, actual_time_out')
          .filter('student_id', 'in', studentIds)
          .filter('event_id', 'in', eventsResponse.map((e) => e['id']).toList()),
      _client
          .from('student_payments')
          .select('student_id, fee_id, status, amount_paid, paid_at, reference_number')
          .filter('student_id', 'in', studentIds)
          .filter('fee_id', 'in', feesResponse.map((f) => f['id']).toList())
          .eq('status', 'Paid'),
      _client
          .from('activity_card_clearance_requests')
          .select('''
            *,
            signatures:activity_card_clearance_signatures (
              *,
              role:roles (name)
            )
          ''')
          .filter('student_id', 'in', studentIds)
          .eq('scope_id', scopeId)
          .eq('academic_term_id', termId)
    ];

    final bulkResults = await Future.wait(futures);
    final allAttendance = bulkResults[0] as List;
    final allPayments = bulkResults[1] as List;
    final allClearances = bulkResults[2] as List;

    // 6. Assemble the ActivityCard objects for each student
    List<ActivityCard> cards = [];

    for (var member in members) {
      final student = member['student'];
      final studentId = student['id'];
      final studentName = '${student['first_name']} ${student['last_name']}';
      final programName = student['program']?['name'] ?? 'N/A';

      final studentAttendance = allAttendance.where((a) => a['student_id'] == studentId).toList();
      final studentPayments = allPayments.where((p) => p['student_id'] == studentId).toList();
      final studentClearance = allClearances.where((c) => c['student_id'] == studentId).firstOrNull;

      final List<ActivityCardEvent> events = eventsResponse.map((e) {
        final attendance = studentAttendance.where((a) => a['event_id'] == e['id']).firstOrNull;
        return ActivityCardEvent(
          id: e['id'],
          eventId: e['id'],
          title: e['name'],
          category: e['scope_type'],
          date: DateTime.parse(e['event_date']),
          attendanceStatus: _mapAttendanceStatus(attendance?['status']),
          completedAt: attendance?['actual_time_out'] != null ? DateTime.parse(attendance!['actual_time_out']) : null,
        );
      }).toList();

      final List<ActivityCardFee> fees = feesResponse.map((f) {
        final payment = studentPayments.where((p) => p['fee_id'] == f['id']).firstOrNull;
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
      if (studentClearance != null && studentClearance['signatures'] != null) {
        final sigList = studentClearance['signatures'] as List;
        for (var i = 0; i < sigList.length; i++) {
          final s = sigList[i];
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

      final completedEvents = events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length;
      final paidFees = fees.where((f) => f.isPaid).length;
      final totalItems = events.length + fees.length;
      final completionPercentage = totalItems > 0 ? (completedEvents + paidFees) / totalItems : 0.0;

      cards.add(ActivityCard(
        id: studentClearance?['id'] ?? 'temp-$studentId',
        studentId: studentId,
        studentName: studentName,
        studentProgram: programName,
        organizationId: organizationId,
        organizationName: orgName,
        organizationLogo: orgLogo,
        organizationType: orgType,
        academicYear: academicYear,
        semester: semester,
        status: _mapClearanceStatus(studentClearance?['status']),
        completionPercentage: completionPercentage,
        events: events,
        fees: fees,
        signatures: signatures,
      ));
    }

    return cards;
  }
}
