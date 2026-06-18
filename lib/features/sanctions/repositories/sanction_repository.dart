import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sanction_model.dart';
import '../models/compliance_member_model.dart';

class SanctionRepository {
  final SupabaseClient _client;

  SanctionRepository(this._client);

  /// Fetches all sanction records for a specific workspace (scope) and term.
  Future<List<SanctionModel>> getWorkspaceSanctions(String scopeId, String termId) async {
    final response = await _client
        .from('student_sanction_records')
        .select('''
          *,
          student:users!student_id (first_name, last_name),
          received_by:users!received_by_user_id (first_name, last_name)
        ''')
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId)
        .order('updated_at', ascending: false);
    
    return (response as List).map((json) {
      final student = json['student'];
      final receivedBy = json['received_by'];
      return SanctionModel.fromJson({
        ...json,
        'student_name': student != null ? '${student['first_name']} ${student['last_name']}' : 'Unknown Student',
        'received_by_name': receivedBy != null ? '${receivedBy['first_name']} ${receivedBy['last_name']}' : null,
      });
    }).toList();
  }

  /// Fetches personal sanction records for a student.
  /// If [scopeId] is provided, filters by that specific workspace/scope.
  Future<List<SanctionModel>> getMySanctions(String studentId, {String? scopeId, String? termId}) async {
    // First attempt: use the ID provided
    var query = _client
        .from('student_sanction_records')
        .select('''
          *,
          student:users!student_id (first_name, last_name),
          received_by:users!received_by_user_id (first_name, last_name)
        ''');
    
    query = query.eq('student_id', studentId);
    if (scopeId != null) query = query.eq('scope_id', scopeId);
    if (termId != null) query = query.eq('academic_term_id', termId);
    
    var response = await query.order('updated_at', ascending: false);
    
    // If empty, check if studentId is actually an auth_id
    if ((response as List).isEmpty) {
      final userLookup = await _client
          .from('users')
          .select('id')
          .eq('auth_id', studentId)
          .maybeSingle();
      
      if (userLookup != null) {
        final internalId = userLookup['id'];
        var retryQuery = _client
            .from('student_sanction_records')
            .select('''
              *,
              student:users!student_id (first_name, last_name),
              received_by:users!received_by_user_id (first_name, last_name)
            ''');
        
        retryQuery = retryQuery.eq('student_id', internalId);
        if (scopeId != null) retryQuery = retryQuery.eq('scope_id', scopeId);
        if (termId != null) retryQuery = retryQuery.eq('academic_term_id', termId);
        
        response = await retryQuery.order('updated_at', ascending: false);
      }
    }
    
    return (response as List).map((json) {
      final student = json['student'];
      final receivedBy = json['received_by'];
      return SanctionModel.fromJson({
        ...json,
        'student_name': student != null ? '${student['first_name']} ${student['last_name']}' : 'Unknown Student',
        'received_by_name': receivedBy != null ? '${receivedBy['first_name']} ${receivedBy['last_name']}' : null,
      });
    }).toList();
  }

  /// Auto-generates sanction records for students with absences in mandatory events based on calculated sanction score.
  Future<void> generateSanctionsForTerm(String termId, String scopeId, String scopeType) async {
    // 1. Get all mandatory events for this scope and term
    final eventsResponse = await _client
        .from('events')
        .select('id')
        .eq('scope_id', scopeId)
        .eq('scope_type', scopeType)
        .eq('academic_term_id', termId)
        .eq('is_mandatory', true);
    
    final eventIds = (eventsResponse as List).map((e) => e['id'] as String).toList();
    if (eventIds.isEmpty) return;

    // 2. Get all sanction rules for this scope and term
    final rulesResponse = await _client
        .from('sanction_rules')
        .select()
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId);
    
    final rules = rulesResponse as List;
    if (rules.isEmpty) return;

    // 3. Lookup organization ID matching the scope
    var orgQuery = _client.from('organizations').select('id');
    if (scopeType == 'Institutional') {
      orgQuery = orgQuery.eq('campus_id', scopeId);
    } else if (scopeType == 'Faculty') {
      orgQuery = orgQuery.eq('faculty_id', scopeId);
    } else if (scopeType == 'Program') {
      orgQuery = orgQuery.eq('program_id', scopeId);
    }
    final orgResult = await orgQuery.limit(1).maybeSingle();
    if (orgResult == null) return;
    final String orgId = orgResult['id'] as String;

    // Get all standard members of this organization (exclude officers)
    final membersResponse = await _client
        .from('organization_members')
        .select('''
          user_id,
          role:roles (name)
        ''')
        .eq('organization_id', orgId);

    final List<Map<String, dynamic>> memberRows = List<Map<String, dynamic>>.from(membersResponse);
    final List<String> allStudentIds = [];
    for (var row in memberRows) {
      final roleData = row['role'];
      final roleName = roleData != null ? roleData['name'] as String? ?? 'Member' : 'Member';
      if (roleName == 'Member' || roleName == 'Students') {
        allStudentIds.add(row['user_id'] as String);
      }
    }

    if (allStudentIds.isEmpty) {
      // Clear all sanction records in this scope and term if there are no members
      await _client
          .from('student_sanction_records')
          .delete()
          .eq('scope_id', scopeId)
          .eq('academic_term_id', termId);
      return;
    }

    // Clean up/delete any existing sanction records for users who are no longer standard members
    await _client
        .from('student_sanction_records')
        .delete()
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId)
        .not('student_id', 'in', allStudentIds);

    // 4. Fetch all attendance records for these events
    final attendanceResponse = await _client
        .from('student_attendance')
        .select('student_id, event_id, actual_time_in, actual_time_out')
        .filter('event_id', 'in', eventIds);
    
    final List<Map<String, dynamic>> attendanceData = List<Map<String, dynamic>>.from(attendanceResponse);
    final Map<String, Map<String, Map<String, dynamic>>> studentAttendanceMap = {};
    for (var row in attendanceData) {
      final studentId = row['student_id'] as String;
      final eventId = row['event_id'] as String;
      studentAttendanceMap.putIfAbsent(studentId, () => {})[eventId] = row;
    }

    // 5. Calculate total sanction score for each student across all mandatory events
    final Map<String, double> studentSanctionScores = {};
    for (var studentId in allStudentIds) {
      double score = 0.0;
      final studentAtt = studentAttendanceMap[studentId];

      for (var eventId in eventIds) {
        final attRecord = studentAtt?[eventId];

        if (attRecord != null) {
          final hasTimeIn = attRecord['actual_time_in'] != null;
          final hasTimeOut = attRecord['actual_time_out'] != null;

          if (hasTimeIn && hasTimeOut) {
            // Present: 0 points
          } else if (hasTimeIn || hasTimeOut) {
            // Partially present: 0.5 points
            score += 0.5;
          } else {
            // Both null: 1.0 point
            score += 1.0;
          }
        } else {
          // No attendance record: 1.0 point
          score += 1.0;
        }
      }

      if (score > 0) {
        studentSanctionScores[studentId] = score;
      }
    }

    // 6. For each student with a sanction score > 0, find the matching sanction rule and create a record
    List<Map<String, dynamic>> sanctionRecords = [];

    studentSanctionScores.forEach((studentId, score) {
      // Find matching rules: min_absence <= score && (max_absence == null || score <= max_absence)
      final matchingRules = rules.where((r) {
        final double minAbs = (r['min_absence'] as num?)?.toDouble() ?? 0.0;
        final double? maxAbs = r['max_absence'] != null ? (r['max_absence'] as num).toDouble() : null;
        return score >= minAbs && (maxAbs == null || score <= maxAbs);
      }).toList();

      if (matchingRules.isNotEmpty) {
        // Sort descending by min_absence, and ascending by max_absence to select the most specific matching rule
        matchingRules.sort((a, b) {
          final double minA = (a['min_absence'] as num?)?.toDouble() ?? 0.0;
          final double minB = (b['min_absence'] as num?)?.toDouble() ?? 0.0;
          final minCompare = minB.compareTo(minA);
          if (minCompare != 0) return minCompare;

          final double? maxA = a['max_absence'] != null ? (a['max_absence'] as num).toDouble() : null;
          final double? maxB = b['max_absence'] != null ? (b['max_absence'] as num).toDouble() : null;
          if (maxA == null && maxB != null) return 1;
          if (maxA != null && maxB == null) return -1;
          if (maxA != null && maxB != null) return maxA.compareTo(maxB);
          return 0;
        });

        final rule = matchingRules.first;
        final worthVal = rule['required_value'];
        final worth = worthVal != null ? ' (Worth: ₱${(worthVal as num).toStringAsFixed(2)})' : '';
        
        sanctionRecords.add({
          'student_id': studentId,
          'scope_type': scopeType,
          'scope_id': scopeId,
          'academic_term_id': termId,
          'total_absences': score, // Stores the computed sanction score
          'required_item': '${rule['item_description']}$worth',
          'status': 'Pending Item',
        });
      }
    });

    if (sanctionRecords.isNotEmpty) {
      // Upsert to avoid duplicates for the same student/scope/term
      await _client.from('student_sanction_records').upsert(
        sanctionRecords, 
        onConflict: 'student_id, scope_id, academic_term_id'
      );
    }
  }

  /// Marks a sanction as received.
  Future<void> receiveSanctionItem(String sanctionId, String officerId) async {
    await _client.from('student_sanction_records').update({
      'status': 'Item Received',
      'received_by_user_id': officerId,
      'received_at': DateTime.now().toIso8601String(),
    }).eq('id', sanctionId);
  }

  /// Fetches compliance statistics for all members of an organization in a specific term.
  Future<List<ComplianceMemberModel>> getOrganizationCompliance({
    required String orgId,
    required String termId,
    required String scopeId,
    required String scopeType,
  }) async {
    // 1. Get all members of the organization
    final membersResponse = await _client
        .from('organization_members')
        .select('''
          *,
          user:users (
            *,
            program:programs!users_program_id_fkey (name),
            faculty:faculties!users_faculty_id_fkey (name)
          ),
          role:roles (name)
        ''')
        .eq('organization_id', orgId);

    // Map unique members (only standard members, exclude officers)
    final List<Map<String, dynamic>> memberRows = List<Map<String, dynamic>>.from(membersResponse);
    final Map<String, Map<String, dynamic>> studentMap = {};
    for (var row in memberRows) {
      final userData = row['user'];
      if (userData == null) continue;
      
      final roleData = row['role'];
      final roleName = roleData != null ? roleData['name'] as String? ?? 'Member' : 'Member';
      if (roleName != 'Member' && roleName != 'Students') {
        continue; // Skip officers
      }
      
      final studentId = userData['id'] as String;
      studentMap[studentId] = row;
    }
    final studentIds = studentMap.keys.toList();

    if (studentIds.isEmpty) return [];

    // 2. Fetch all mandatory events for this scope and term
    final eventsResponse = await _client
        .from('events')
        .select('id')
        .eq('scope_id', scopeId)
        .eq('scope_type', scopeType)
        .eq('academic_term_id', termId)
        .eq('is_mandatory', true);
    
    final eventIds = (eventsResponse as List).map((e) => e['id'] as String).toList();

    // 3. Fetch attendance records for these events
    final Map<String, Map<String, Map<String, dynamic>>> studentAttendanceMap = {};
    if (eventIds.isNotEmpty) {
      final attendanceResponse = await _client
          .from('student_attendance')
          .select('student_id, event_id, actual_time_in, actual_time_out')
          .filter('event_id', 'in', eventIds)
          .filter('student_id', 'in', studentIds);
      
      for (var row in (attendanceResponse as List)) {
        final studentId = row['student_id'] as String;
        final eventId = row['event_id'] as String;
        studentAttendanceMap
            .putIfAbsent(studentId, () => {})[eventId] = row;
      }
    }

    // 4. Build list of ComplianceMemberModel with real-time calculated sanction score
    final List<ComplianceMemberModel> complianceList = [];
    studentMap.forEach((studentId, row) {
      final userData = row['user'];
      final programData = userData['program'];
      
      final schoolId = userData['student_id_number'] as String? ?? 'N/A';
      final firstName = userData['first_name'] as String? ?? '';
      final lastName = userData['last_name'] as String? ?? '';
      final name = '$firstName $lastName'.trim();
      final program = programData != null ? programData['name'] as String? ?? 'N/A' : 'N/A';
      final year = userData['year'] as int?;
      
      double computedSanctionScore = 0.0;
      int attendedCount = 0;
      final totalMandatory = eventIds.length;

      for (var eventId in eventIds) {
        final studentAtt = studentAttendanceMap[studentId];
        final attRecord = studentAtt?[eventId];

        if (attRecord != null) {
          final hasTimeIn = attRecord['actual_time_in'] != null;
          final hasTimeOut = attRecord['actual_time_out'] != null;

          if (hasTimeIn && hasTimeOut) {
            // Present: 0 points
            attendedCount++;
          } else if (hasTimeIn || hasTimeOut) {
            // Partially present: 0.5 points
            computedSanctionScore += 0.5;
            attendedCount++;
          } else {
            // Both null: 1.0 point
            computedSanctionScore += 1.0;
          }
        } else {
          // No attendance record: 1.0 point
          computedSanctionScore += 1.0;
        }
      }

      complianceList.add(ComplianceMemberModel(
        studentId: studentId,
        schoolId: schoolId,
        name: name.isEmpty ? 'Unknown' : name,
        program: program,
        year: year,
        attendedEvents: attendedCount,
        totalMandatoryEvents: totalMandatory,
        sanctionScore: computedSanctionScore,
      ));
    });

    return complianceList;
  }

  /// Fetches attendance details for a specific student across all mandatory events in a specific term.
  Future<List<Map<String, dynamic>>> getStudentAttendanceForSanctions({
    required String studentId,
    required String termId,
    required String scopeId,
    required String scopeType,
  }) async {
    // 1. Fetch all mandatory events for this scope and term
    final eventsResponse = await _client
        .from('events')
        .select('*, created_by_user:users!events_created_by_user_id_fkey(first_name, last_name)')
        .eq('scope_id', scopeId)
        .eq('scope_type', scopeType)
        .eq('academic_term_id', termId)
        .eq('is_mandatory', true)
        .order('event_date', ascending: true);

    final List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(eventsResponse);
    if (events.isEmpty) return [];

    final eventIds = events.map((e) => e['id'] as String).toList();

    // 2. Fetch the student's attendance records for these events
    final attendanceResponse = await _client
        .from('student_attendance')
        .select()
        .eq('student_id', studentId)
        .filter('event_id', 'in', eventIds);

    final List<Map<String, dynamic>> attendanceRows = List<Map<String, dynamic>>.from(attendanceResponse);
    final Map<String, Map<String, dynamic>> attendanceMap = {
      for (var row in attendanceRows) row['event_id'] as String: row
    };

    // 3. Map events to their status and calculated sanction score contribution
    return events.map((event) {
      final eventId = event['id'] as String;
      final attendance = attendanceMap[eventId];

      String? timeIn;
      String? timeOut;
      double score = 1.0;

      if (attendance != null) {
        timeIn = attendance['actual_time_in'];
        timeOut = attendance['actual_time_out'];
        
        final hasTimeIn = timeIn != null;
        final hasTimeOut = timeOut != null;

        if (hasTimeIn && hasTimeOut) {
          score = 0.0;
        } else if (hasTimeIn || hasTimeOut) {
          score = 0.5;
        } else {
          score = 1.0;
        }
      }

      return {
        'event_id': eventId,
        'name': event['name'],
        'date': event['event_date'],
        'time_in': timeIn,
        'time_out': timeOut,
        'sanction_score': score,
      };
    }).toList();
  }

  /// Fetches a student's sanction record for a specific scope and term.
  Future<SanctionModel?> getStudentSanctionRecord({
    required String studentId,
    required String termId,
    required String scopeId,
  }) async {
    final response = await _client
        .from('student_sanction_records')
        .select('''
          *,
          received_by:users!received_by_user_id (first_name, last_name)
        ''')
        .eq('student_id', studentId)
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId)
        .maybeSingle();

    if (response == null) return null;

    final receivedBy = response['received_by'];
    return SanctionModel.fromJson({
      ...response,
      'received_by_name': receivedBy != null ? '${receivedBy['first_name']} ${receivedBy['last_name']}' : null,
    });
  }
}
