import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activity_card_models.dart';

class ActivityCardRepository {
  final SupabaseClient _client;

  ActivityCardRepository(this._client);

  Future<List<ActivityCard>> getStudentActivityCards(String studentId) async {
    // 1. Get active term
    final termResponseList = await _client
        .from('academic_terms')
        .select()
        .eq('is_active', true)
        .limit(1);
    
    if (termResponseList.isEmpty) return [];
    final termResponse = termResponseList.first;
    
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
          .eq('is_mandatory', true)
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
              roles (name),
              signed_by_user:users!signed_by_user_id (first_name, last_name)
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
      final orgCode = org['code'] ?? 'N/A';

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

      // 1. Map signatures first to determine if Secretary/Treasurer have signed
      final List<ActivityCardSignature> signatures = [];
      if (clearanceResponse != null && clearanceResponse['activity_card_clearance_signatures'] != null) {
        final sigList = clearanceResponse['activity_card_clearance_signatures'] as List;
        for (var i = 0; i < sigList.length; i++) {
          final s = sigList[i];
          final roleData = s['roles'];
          final rawRoleName = roleData is List ? roleData.first['name'] as String : roleData['name'] as String;
          final roleName = rawRoleName == 'Instructor' ? 'Adviser' : rawRoleName;
          
          final userData = s['signed_by_user'];
          String? signedByName;
          if (userData != null) {
            final fName = userData['first_name'] as String?;
            final lName = userData['last_name'] as String?;
            if (fName != null || lName != null) {
              signedByName = '${fName ?? ''} ${lName ?? ''}'.trim();
            }
          }

          signatures.add(ActivityCardSignature(
            id: s['id'],
            roleName: roleName,
            signedByUserId: s['signed_by_user_id'],
            signedByUserName: signedByName,
            status: _mapSignatureStatus(s['status']),
            signedAt: s['signed_at'] != null ? DateTime.parse(s['signed_at']) : null,
            rejectionReason: s['remarks'],
            order: _getRoleOrder(roleName),
          ));
        }
        // Sort signatures by role order hierarchy
        signatures.sort((a, b) => a.order.compareTo(b.order));
      }

      final bool isSecretarySigned = signatures.any((s) => s.roleName == 'Secretary' && s.status == SignatureStatus.signed);
      final bool isTreasurerSigned = signatures.any((s) => s.roleName == 'Treasurer' && s.status == SignatureStatus.signed);

      // 2. Map sanctions first
      final List<ActivityCardSanction> sanctions = sanctionsResponse.map((s) {
        return ActivityCardSanction(
          id: s['id'],
          description: s['required_item'],
          isFulfilled: s['status'] == 'Item Received',
          fulfilledAt: s['received_at'] != null ? DateTime.parse(s['received_at']) : null,
        );
      }).toList();

      final bool sanctionsCleared = sanctions.isNotEmpty && sanctions.every((s) => s.isFulfilled);

      // 3. Map events (applying sanctionCleared if all sanctions are completed)
      final List<ActivityCardEvent> events = eventsResponse.map((e) {
        final attendance = (e['attendance'] as List).firstOrNull;
        var status = _mapAttendanceStatus(attendance?['status']);
        final hasTimeIn = attendance?['actual_time_in'] != null;
        final hasTimeOut = attendance?['actual_time_out'] != null;
        if (status == AttendanceStatus.completed && !(hasTimeIn && hasTimeOut)) {
          status = AttendanceStatus.pending;
        }
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
          verifiedBy: isSecretarySigned ? '$orgCode SECRETARY' : null,
          completedAt: attendance?['actual_time_out'] != null 
            ? DateTime.parse(attendance!['actual_time_out']) 
            : null,
        );
      }).toList();

      // 4. Map fees
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
          verifiedBy: isTreasurerSigned ? '$orgCode TREASURER' : null,
        );
      }).toList();

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

      final clearedAtStr = clearanceResponse?['completed_at'] ?? clearanceResponse?['updated_at'] ?? clearanceResponse?['requested_at'];
      final DateTime? clearedAt = clearedAtStr != null ? DateTime.parse(clearedAtStr) : null;

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
        clearedAt: clearedAt,
        organizationCode: orgCode,
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
    final hasProgramHead = signatures.any((s) => s.roleName == 'Program Head');
    final hasFacultyDean = signatures.any((s) => s.roleName == 'Faculty Dean');

    final isSecretarySigned = !hasSecretary || signatures.where((s) => s.roleName == 'Secretary').every((s) => s.status == SignatureStatus.signed);
    final isTreasurerSigned = !hasTreasurer || signatures.where((s) => s.roleName == 'Treasurer').every((s) => s.status == SignatureStatus.signed);
    final isGovernorSigned = !hasGovernor || signatures.where((s) => s.roleName == 'Governor' || s.roleName == 'President').every((s) => s.status == SignatureStatus.signed);
    final isAdviserSigned = !hasAdviser || signatures.where((s) => s.roleName == 'Instructor' || s.roleName == 'Adviser').every((s) => s.status == SignatureStatus.signed);
    final isProgramHeadSigned = !hasProgramHead || signatures.where((s) => s.roleName == 'Program Head').every((s) => s.status == SignatureStatus.signed);
    final isFacultyDeanSigned = !hasFacultyDean || signatures.where((s) => s.roleName == 'Faculty Dean').every((s) => s.status == SignatureStatus.signed);

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
    if (!isProgramHeadSigned) {
      return ActivityCardStatus.programHeadReview;
    }
    if (!isFacultyDeanSigned) {
      return ActivityCardStatus.deanReview;
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

  int _getRoleOrder(String roleName) {
    final name = roleName.toLowerCase().trim();
    if (name == 'secretary') return 1;
    if (name == 'treasurer') return 2;
    if (name == 'governor' || name == 'president') return 3;
    if (name == 'instructor' || name == 'adviser') return 4;
    if (name == 'program head') return 5;
    if (name == 'faculty dean' || name == 'dean') return 6;
    return 7;
  }

  Future<List<ActivityCard>> getOrganizationActivityCards(String organizationId) async {
    // 1. Get active term
    final termResponseList = await _client
        .from('academic_terms')
        .select()
        .eq('is_active', true)
        .limit(1);
    
    if (termResponseList.isEmpty) return [];
    final termResponse = termResponseList.first;
    final termId = termResponse['id'];
    final academicYear = termResponse['academic_year'];
    final semester = termResponse['semester'];

    // 2. Get organization info and its scope
    final orgResponseList = await _client
        .from('organizations')
        .select()
        .eq('id', organizationId)
        .limit(1);
    final orgResponse = orgResponseList.isEmpty ? null : orgResponseList.first;
    
    String? orgType;
    String? orgName;
    String? orgLogo;
    String? scopeId;
    String? orgCode;

    if (orgResponse != null) {
      orgType = orgResponse['type'];
      orgName = orgResponse['name'];
      orgLogo = orgResponse['logo_url'];
      orgCode = orgResponse['code'];
      scopeId = orgResponse['campus_id'];
      if (orgType == 'faculty-based') {
        scopeId = orgResponse['faculty_id'];
      } else if (orgType == 'program-based') {
        scopeId = orgResponse['program_id'];
      }
    } else {
      // Check if it is a Program workspace
      final programResponseList = await _client
          .from('programs')
          .select()
          .eq('id', organizationId)
          .limit(1);
      final programResponse = programResponseList.isEmpty ? null : programResponseList.first;
      
      if (programResponse != null) {
        orgType = 'program-based';
        orgName = programResponse['name'];
        orgLogo = programResponse['logo_url'];
        orgCode = programResponse['code'];
        scopeId = organizationId;
      } else {
        // Check if it is a Faculty workspace
        final facultyResponseList = await _client
            .from('faculties')
            .select()
            .eq('id', organizationId)
            .limit(1);
        final facultyResponse = facultyResponseList.isEmpty ? null : facultyResponseList.first;
        
        if (facultyResponse != null) {
          orgType = 'faculty-based';
          orgName = facultyResponse['name'];
          orgLogo = facultyResponse['logo_url'];
          orgCode = facultyResponse['code'];
          scopeId = organizationId;
        }
      }
    }

    if (scopeId == null) return [];

    // 3. Get all students (members)
    final List<Map<String, dynamic>> normalizedMembers = [];
    if (orgResponse != null) {
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
              program:programs!users_program_id_fkey (code),
              faculty:faculties!users_faculty_id_fkey (code)
            )
          ''')
          .eq('organization_id', organizationId)
          .eq('status', 'active');
      
      final members = membersResponse as List;
      for (var m in members) {
        final student = m['student'];
        if (student != null) {
          normalizedMembers.add({
            'student_id': student['id'],
            'student_id_number': student['student_id_number'],
            'student_name': '${student['first_name']} ${student['last_name']}',
            'program_name': student['program']?['code'] ?? 'N/A',
            'faculty_name': student['faculty']?['code'] ?? 'N/A',
            'is_officer': ((m['roles']?['hierarchy_level'] ?? 5) as num) > 5,
          });
        }
      }
    } else {
      // It's a Program or Faculty workspace, query students directly from users table
      final isProgram = (orgType == 'program-based');
      final usersResponse = await _client
          .from('users')
          .select('''
            id,
            first_name,
            last_name,
            student_id_number,
            faculty_id,
            program_id,
            program:programs!users_program_id_fkey (code, faculty_id),
            faculty:faculties!users_faculty_id_fkey (code)
          ''')
          .eq('account_status', 'active');

      final usersList = usersResponse as List;
      for (var u in usersList) {
        final matches = isProgram
            ? (u['program_id'] == organizationId)
            : (u['faculty_id'] == organizationId || u['program']?['faculty_id'] == organizationId);
            
        if (matches) {
          normalizedMembers.add({
            'student_id': u['id'],
            'student_id_number': u['student_id_number'],
            'student_name': '${u['first_name']} ${u['last_name']}',
            'program_name': u['program']?['code'] ?? 'N/A',
            'faculty_name': u['faculty']?['code'] ?? 'N/A',
            'is_officer': false,
          });
        }
      }
    }

    if (normalizedMembers.isEmpty) return [];
    final studentIds = normalizedMembers.map((m) => m['student_id'] as String).toList();

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
        .eq('academic_term_id', termId)
        .eq('is_mandatory', true);

    var sanctionsQuery = _client
        .from('student_sanction_records')
        .select()
        .filter('student_id', 'in', studentIds)
        .eq('academic_term_id', termId);

    if (orgResponse != null) {
      sanctionsQuery = sanctionsQuery.eq('scope_id', organizationId);
    }

    // 5. Get all attendance, payments, and clearance requests for these students in bulk
    final List<Future<dynamic>> futures = [
      eventsResponse.isEmpty
          ? Future.value(<dynamic>[])
          : _client
              .from('student_attendance')
              .select('student_id, event_id, status, actual_time_in, actual_time_out')
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
      sanctionsQuery,
      _client
          .from('activity_card_clearance_requests')
          .select('''
            *,
            activity_card_clearance_signatures (
              *,
              roles (name),
              signed_by_user:users!signed_by_user_id (first_name, last_name)
            )
          ''')
          .filter('student_id', 'in', studentIds)
          .eq(orgResponse != null ? 'organization_id' : 'scope_id', organizationId)
          .eq('academic_term_id', termId)
    ];

    final bulkResults = await Future.wait(futures);
    final allAttendance = bulkResults[0] as List;
    final allPayments = bulkResults[1] as List;
    final allSanctions = bulkResults[2] as List;
    final allClearances = bulkResults[3] as List;

    // 6. Assemble the ActivityCard objects for each student
    List<ActivityCard> cards = [];

    for (var member in normalizedMembers) {
      final studentId = member['student_id'] as String;
      final studentName = member['student_name'] as String;
      final programName = member['program_name'] as String;
      final isOfficer = member['is_officer'] as bool;

      final studentAttendance = allAttendance.where((a) => a['student_id'] == studentId).toList();
      final studentPayments = allPayments.where((p) => p['student_id'] == studentId).toList();
      final studentSanctions = allSanctions.where((s) => s['student_id'] == studentId).toList();
      final studentClearance = allClearances.where((c) => c['student_id'] == studentId).firstOrNull;

      // 1. Map signatures first to check Secretary/Treasurer status
      final List<ActivityCardSignature> signatures = [];
      if (studentClearance != null && studentClearance['activity_card_clearance_signatures'] != null) {
        final sigList = studentClearance['activity_card_clearance_signatures'] as List;
        for (var i = 0; i < sigList.length; i++) {
          final s = sigList[i];
          final roleData = s['roles'];
          final rawRoleName = roleData is List ? roleData.first['name'] as String : roleData['name'] as String;
          final roleName = rawRoleName == 'Instructor' ? 'Adviser' : rawRoleName;

          final userData = s['signed_by_user'];
          String? signedByName;
          if (userData != null) {
            final fName = userData['first_name'] as String?;
            final lName = userData['last_name'] as String?;
            if (fName != null || lName != null) {
              signedByName = '${fName ?? ''} ${lName ?? ''}'.trim();
            }
          }

          signatures.add(ActivityCardSignature(
            id: s['id'],
            roleName: roleName,
            signedByUserId: s['signed_by_user_id'],
            signedByUserName: signedByName,
            status: _mapSignatureStatus(s['status']),
            signedAt: s['signed_at'] != null ? DateTime.parse(s['signed_at']) : null,
            rejectionReason: s['remarks'],
            order: _getRoleOrder(roleName),
          ));
        }
        // Sort signatures by role order hierarchy
        signatures.sort((a, b) => a.order.compareTo(b.order));
      }

      final bool isSecretarySigned = signatures.any((s) => s.roleName == 'Secretary' && s.status == SignatureStatus.signed);
      final bool isTreasurerSigned = signatures.any((s) => s.roleName == 'Treasurer' && s.status == SignatureStatus.signed);

      // 2. Map sanctions first
      final List<ActivityCardSanction> sanctions = studentSanctions.map((s) {
        return ActivityCardSanction(
          id: s['id'],
          description: s['required_item'],
          isFulfilled: s['status'] == 'Item Received',
          fulfilledAt: s['received_at'] != null ? DateTime.parse(s['received_at']) : null,
        );
      }).toList();

      final bool sanctionsCleared = sanctions.isNotEmpty && sanctions.every((s) => s.isFulfilled);

      // 3. Map events (applying sanctionCleared if all sanctions are completed)
      final List<ActivityCardEvent> events = eventsResponse.map((e) {
        final attendance = studentAttendance.where((a) => a['event_id'] == e['id']).firstOrNull;
        var status = _mapAttendanceStatus(attendance?['status']);
        final hasTimeIn = attendance?['actual_time_in'] != null;
        final hasTimeOut = attendance?['actual_time_out'] != null;
        if (status == AttendanceStatus.completed && !(hasTimeIn && hasTimeOut)) {
          status = AttendanceStatus.pending;
        }
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
          verifiedBy: isSecretarySigned ? '${orgCode ?? 'N/A'} SECRETARY' : null,
          completedAt: attendance?['actual_time_out'] != null ? DateTime.parse(attendance!['actual_time_out']) : null,
        );
      }).toList();

      // 4. Map fees
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
          verifiedBy: isTreasurerSigned ? '${orgCode ?? 'N/A'} TREASURER' : null,
        );
      }).toList();

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

      final clearedAtStr = studentClearance?['completed_at'] ?? studentClearance?['updated_at'] ?? studentClearance?['requested_at'];
      final DateTime? clearedAt = clearedAtStr != null ? DateTime.parse(clearedAtStr) : null;

      cards.add(ActivityCard(
        id: studentClearance?['id'] ?? 'temp-$studentId',
        studentId: studentId,
        studentIdNumber: member['student_id_number'] as String?,
        studentName: studentName,
        studentFaculty: member['faculty_name'] as String?,
        studentProgram: programName,
        organizationId: organizationId,
        organizationName: orgName ?? 'N/A',
        organizationLogo: orgLogo,
        organizationType: orgType ?? 'campus-based',
        academicYear: academicYear,
        semester: semester,
        status: cardStatus,
        isOfficer: isOfficer,
        completionPercentage: completionPercentage,
        events: events,
        fees: fees,
        sanctions: sanctions,
        signatures: signatures,
        clearedAt: clearedAt,
        organizationCode: orgCode ?? 'N/A',
      ));
    }

    return cards;
  }

  Future<ActivityCard?> getStudentActivityCardForOrganization(String studentId, String organizationId) async {
    final cards = await getOrganizationActivityCards(organizationId);
    return cards.where((c) => c.studentId == studentId).firstOrNull;
  }
}
