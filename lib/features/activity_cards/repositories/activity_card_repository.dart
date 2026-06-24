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
        .select('organization_id, organizations(*), roles(hierarchy_level)')
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

    // Collect all organization IDs for clearance requests
    final List<String> orgIds = orgMembers.map((m) => m['organization_id'] as String).toList();

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
          .eq('is_mandatory', true)
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
          .from('student_sanction_records')
          .select()
          .filter('scope_id', 'in', orgIds)
          .eq('academic_term_id', termId)
          .eq('student_id', studentId),
      _client
          .from('activity_card_clearance_requests')
          .select('''
            *,
            activity_card_clearance_signatures (
              *,
              roles (name)
            )
          ''')
          .eq('student_id', studentId)
          .filter('organization_id', 'in', orgIds)
          .eq('academic_term_id', termId)
    ];

    final results = await Future.wait(futures);

    final allEvents = results[0] as List;
    final allFees = results[1] as List;
    final allSanctions = results[2] as List;
    final allClearanceRequests = results[3] as List;

    List<ActivityCard> cards = [];

    for (var member in orgMembers) {
      final org = member['organizations'];
      final orgId = org['id'];
      final orgName = org['name'];
      final orgLogo = org['logo_url'];
      final orgType = org['type'];

      final roleData = member['roles'];
      final hierarchyLevel = roleData?['hierarchy_level'] ?? 5;
      final isOfficer = (hierarchyLevel as num) > 5;

      // Determine scope for events/fees
      String? scopeId = org['campus_id'];
      if (orgType == 'faculty-based') {
        scopeId = org['faculty_id'];
      } else if (orgType == 'program-based') {
        scopeId = org['program_id'];
      }

      if (scopeId == null) continue;

      // Filter bulk results for this organization
      final eventsResponse = allEvents.where((e) => e['scope_id'] == scopeId).toList();
      final feesResponse = allFees.where((f) => f['scope_id'] == scopeId).toList();
      final sanctionsResponse = allSanctions.where((s) => s['scope_id'] == orgId).toList();
      final clearanceResponse = allClearanceRequests.where((c) => c['organization_id'] == orgId).firstOrNull;

      // 1. Map sanctions first
      final List<ActivityCardSanction> sanctions = sanctionsResponse.map((s) {
        return ActivityCardSanction(
          id: s['id'],
          description: s['required_item'],
          isFulfilled: s['status'] == 'Item Received',
          fulfilledAt: s['received_at'] != null ? DateTime.parse(s['received_at']) : null,
        );
      }).toList();

      final bool sanctionsCleared = sanctions.isNotEmpty && sanctions.every((s) => s.isFulfilled);

      // 2. Map events (applying sanctionCleared if all sanctions are completed)
      final List<ActivityCardEvent> events = eventsResponse.map((e) {
        final attendance = (e['attendance'] as List).firstOrNull;
        var status = _mapAttendanceStatus(attendance?['status']);
        final isPast = _isPastEvent(e);
        if ((status == AttendanceStatus.absent || (status == AttendanceStatus.pending && isPast)) && sanctionsCleared) {
          status = AttendanceStatus.sanctionCleared;
        }
        return ActivityCardEvent(
          id: e['id'],
          eventId: e['id'],
          title: e['name'],
          category: e['scope_type'],
          date: DateTime.parse(e['event_date']),
          attendanceStatus: status,
          completedAt: attendance?['actual_time_out'] != null 
            ? DateTime.parse(attendance!['actual_time_out']) 
            : null,
        );
      }).toList();

      // 3. Map fees
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

      // 4. Map signatures
      final List<ActivityCardSignature> signatures = [];
      if (clearanceResponse != null && clearanceResponse['activity_card_clearance_signatures'] != null) {
        final sigList = clearanceResponse['activity_card_clearance_signatures'] as List;
        for (var i = 0; i < sigList.length; i++) {
          final s = sigList[i];
          final roleData = s['roles'];
          final roleName = roleData is List ? roleData.first['name'] : roleData['name'];
          
          signatures.add(ActivityCardSignature(
            id: s['id'],
            roleName: roleName,
            signedByUserId: s['signed_by_user_id'],
            status: _mapSignatureStatus(s['status']),
            signedAt: s['signed_at'] != null ? DateTime.parse(s['signed_at']) : null,
            rejectionReason: s['remarks'],
            order: i,
          ));
        }
      }

      // 5. Calculate completion
      final completedEvents = events.where((e) => e.attendanceStatus == AttendanceStatus.completed || e.attendanceStatus == AttendanceStatus.excused || e.attendanceStatus == AttendanceStatus.sanctionCleared).length;
      final paidFees = fees.where((f) => f.isPaid).length;
      final fulfilledSanctions = sanctions.where((s) => s.isFulfilled).length;
      final totalItems = events.length + fees.length + sanctions.length;
      final completionPercentage = totalItems > 0 
        ? (completedEvents + paidFees + fulfilledSanctions) / totalItems 
        : 0.0;

      final cardStatus = _determineActivityCardStatus(
        clearanceResponse?['status'],
        signatures,
        completionPercentage,
      );

      cards.add(ActivityCard(
        id: clearanceResponse?['id'] ?? 'temp-$orgId',
        studentId: studentId,
        organizationId: orgId,
        organizationName: orgName,
        organizationLogo: orgLogo,
        organizationType: orgType,
        academicYear: academicYear,
        semester: semester,
        status: cardStatus,
        isOfficer: isOfficer,
        completionPercentage: completionPercentage,
        events: events,
        fees: fees,
        sanctions: sanctions,
        signatures: signatures,
      ));
    }

    return cards;
  }

  ActivityCardStatus _determineActivityCardStatus(
    String? dbStatus, 
    List<ActivityCardSignature> signatures, 
    double completionPercentage
  ) {
    if (dbStatus == null) {
      return completionPercentage > 0 
          ? ActivityCardStatus.inProgress 
          : ActivityCardStatus.draft;
    }

    if (dbStatus == 'Rejected') {
      return ActivityCardStatus.rejected;
    }

    if (dbStatus == 'Cleared') {
      return ActivityCardStatus.cleared;
    }

    // If Pending in the database, determine based on signatures:
    final hasSecretary = signatures.any((s) => s.roleName == 'Secretary');
    final hasTreasurer = signatures.any((s) => s.roleName == 'Treasurer');
    final hasGovernor = signatures.any((s) => s.roleName == 'Governor' || s.roleName == 'President');
    final hasAdviser = signatures.any((s) => s.roleName == 'Instructor' || s.roleName == 'Adviser');

    final isSecretarySigned = !hasSecretary || signatures.where((s) => s.roleName == 'Secretary').every((s) => s.status == SignatureStatus.signed);
    final isTreasurerSigned = !hasTreasurer || signatures.where((s) => s.roleName == 'Treasurer').every((s) => s.status == SignatureStatus.signed);
    final isGovernorSigned = !hasGovernor || signatures.where((s) => s.roleName == 'Governor' || s.roleName == 'President').every((s) => s.status == SignatureStatus.signed);
    final isAdviserSigned = !hasAdviser || signatures.where((s) => s.roleName == 'Instructor' || s.roleName == 'Adviser').every((s) => s.status == SignatureStatus.signed);

    if (!isSecretarySigned) {
      return ActivityCardStatus.secretaryReview;
    }
    if (!isTreasurerSigned) {
      return ActivityCardStatus.treasurerReview;
    }
    if (!isGovernorSigned) {
      return ActivityCardStatus.governorReview;
    }
    if (!isAdviserSigned) {
      return ActivityCardStatus.adviserReview;
    }

    return ActivityCardStatus.cleared;
  }

  bool _isPastEvent(Map e) {
    try {
      final eventDate = DateTime.parse(e['event_date']);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      if (eventDate.isBefore(todayStart)) return true;
      if (eventDate.isAfter(todayStart)) return false;
      
      final timeOutEndStr = e['time_out_end'] as String?;
      if (timeOutEndStr != null) {
        final parts = timeOutEndStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final timeoutEnd = DateTime(today.year, today.month, today.day, hour, minute);
        return today.isAfter(timeoutEnd);
      }
    } catch (_) {}
    return false;
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
          roles(hierarchy_level),
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
        .select('id, name, scope_type, event_date, time_out_end')
        .eq('scope_id', scopeId)
        .eq('is_mandatory', true)
        .eq('academic_term_id', termId);
    
    final feesResponse = await _client
        .from('fees')
        .select('id, name, scope_type, amount')
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId);

    // 5. Get all attendance, payments, and clearance requests for these students in bulk
    final List<Future<dynamic>> futures = [
      eventsResponse.isEmpty
          ? Future.value(<dynamic>[])
          : _client
              .from('student_attendance')
              .select('student_id, event_id, status, actual_time_out')
              .filter('student_id', 'in', studentIds)
              .filter('event_id', 'in', eventsResponse.map((e) => e['id']).toList()),
      feesResponse.isEmpty
          ? Future.value(<dynamic>[])
          : _client
              .from('student_payments')
              .select('student_id, fee_id, status, amount_paid, paid_at, reference_number')
              .filter('student_id', 'in', studentIds)
              .filter('fee_id', 'in', feesResponse.map((f) => f['id']).toList())
              .eq('status', 'Paid'),
      _client
          .from('student_sanction_records')
          .select()
          .filter('student_id', 'in', studentIds)
          .eq('scope_id', organizationId)
          .eq('academic_term_id', termId),
      _client
          .from('activity_card_clearance_requests')
          .select('''
            *,
            activity_card_clearance_signatures (
              *,
              roles (name)
            )
          ''')
          .filter('student_id', 'in', studentIds)
          .eq('organization_id', organizationId)
          .eq('academic_term_id', termId)
    ];

    final bulkResults = await Future.wait(futures);
    final allAttendance = bulkResults[0] as List;
    final allPayments = bulkResults[1] as List;
    final allSanctions = bulkResults[2] as List;
    final allClearances = bulkResults[3] as List;

    // 6. Assemble the ActivityCard objects for each student
    List<ActivityCard> cards = [];

    for (var member in members) {
      final student = member['student'];
      final studentId = student['id'];
      final studentName = '${student['first_name']} ${student['last_name']}';
      final programName = student['program']?['name'] ?? 'N/A';

      final roleData = member['roles'];
      final hierarchyLevel = roleData?['hierarchy_level'] ?? 5;
      final isOfficer = (hierarchyLevel as num) > 5;

      final studentAttendance = allAttendance.where((a) => a['student_id'] == studentId).toList();
      final studentPayments = allPayments.where((p) => p['student_id'] == studentId).toList();
      final studentSanctions = allSanctions.where((s) => s['student_id'] == studentId).toList();
      final studentClearance = allClearances.where((c) => c['student_id'] == studentId).firstOrNull;

      // 1. Map sanctions first
      final List<ActivityCardSanction> sanctions = studentSanctions.map((s) {
        return ActivityCardSanction(
          id: s['id'],
          description: s['required_item'],
          isFulfilled: s['status'] == 'Item Received',
          fulfilledAt: s['received_at'] != null ? DateTime.parse(s['received_at']) : null,
        );
      }).toList();

      final bool sanctionsCleared = sanctions.isNotEmpty && sanctions.every((s) => s.isFulfilled);

      // 2. Map events (applying sanctionCleared if all sanctions are completed)
      final List<ActivityCardEvent> events = eventsResponse.map((e) {
        final attendance = studentAttendance.where((a) => a['event_id'] == e['id']).firstOrNull;
        var status = _mapAttendanceStatus(attendance?['status']);
        final isPast = _isPastEvent(e);
        if ((status == AttendanceStatus.absent || (status == AttendanceStatus.pending && isPast)) && sanctionsCleared) {
          status = AttendanceStatus.sanctionCleared;
        }
        return ActivityCardEvent(
          id: e['id'],
          eventId: e['id'],
          title: e['name'],
          category: e['scope_type'],
          date: DateTime.parse(e['event_date']),
          attendanceStatus: status,
          completedAt: attendance?['actual_time_out'] != null ? DateTime.parse(attendance!['actual_time_out']) : null,
        );
      }).toList();

      // 3. Map fees
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

      // 4. Map signatures
      final List<ActivityCardSignature> signatures = [];
      if (studentClearance != null && studentClearance['activity_card_clearance_signatures'] != null) {
        final sigList = studentClearance['activity_card_clearance_signatures'] as List;
        for (var i = 0; i < sigList.length; i++) {
          final s = sigList[i];
          final roleData = s['roles'];
          final roleName = roleData is List ? roleData.first['name'] : roleData['name'];

          signatures.add(ActivityCardSignature(
            id: s['id'],
            roleName: roleName,
            signedByUserId: s['signed_by_user_id'],
            status: _mapSignatureStatus(s['status']),
            signedAt: s['signed_at'] != null ? DateTime.parse(s['signed_at']) : null,
            rejectionReason: s['remarks'],
            order: i,
          ));
        }
      }

      // 5. Calculate completion
      final completedEvents = events.where((e) => e.attendanceStatus == AttendanceStatus.completed || e.attendanceStatus == AttendanceStatus.excused || e.attendanceStatus == AttendanceStatus.sanctionCleared).length;
      final paidFees = fees.where((f) => f.isPaid).length;
      final fulfilledSanctions = sanctions.where((s) => s.isFulfilled).length;
      final totalItems = events.length + fees.length + sanctions.length;
      final completionPercentage = totalItems > 0 ? (completedEvents + paidFees + fulfilledSanctions) / totalItems : 0.0;

      final cardStatus = _determineActivityCardStatus(
        studentClearance?['status'],
        signatures,
        completionPercentage,
      );

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
        status: cardStatus,
        isOfficer: isOfficer,
        completionPercentage: completionPercentage,
        events: events,
        fees: fees,
        sanctions: sanctions,
        signatures: signatures,
      ));
    }

    return cards;
  }

  Future<ActivityCard?> getStudentActivityCardForOrganization(String studentId, String organizationId) async {
    final cards = await getOrganizationActivityCards(organizationId);
    return cards.where((c) => c.studentId == studentId).firstOrNull;
  }
}
