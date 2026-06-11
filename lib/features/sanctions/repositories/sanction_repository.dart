import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sanction_model.dart';

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

  /// Auto-generates sanction records for students with absences in mandatory events.
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

    // 3. Get all students in this scope
    var studentsQuery = _client.from('users').select('id');
    if (scopeType == 'Institutional') {
      studentsQuery = studentsQuery.eq('campus_id', scopeId);
    } else if (scopeType == 'Faculty') {
      studentsQuery = studentsQuery.eq('faculty_id', scopeId);
    } else if (scopeType == 'Program') {
      studentsQuery = studentsQuery.eq('program_id', scopeId);
    }
    
    final studentsResponse = await studentsQuery;
    final allStudentIds = (studentsResponse as List).map((s) => s['id'] as String).toList();
    if (allStudentIds.isEmpty) return;

    // 4. Identify students with absences
    // We count as absent anyone who is NOT 'Present', 'Late', or 'Excused' for a mandatory event
    final attendanceResponse = await _client
        .from('student_attendance')
        .select('student_id, event_id, status')
        .filter('event_id', 'in', eventIds);
    
    // Create a map studentId -> Set of attended eventIds
    final Map<String, Set<String>> attendedEvents = {};
    final attendanceData = attendanceResponse as List;
    
    for (var row in attendanceData) {
      final studentId = row['student_id'] as String;
      final eventId = row['event_id'] as String;
      final status = row['status'] as String;
      
      // Statuses that count as "cleared" for attendance
      if (status == 'Present' || status == 'Late' || status == 'Excused') {
        attendedEvents.putIfAbsent(studentId, () => {}).add(eventId);
      }
    }

    // 5. Calculate total absences for each student across all mandatory events
    final Map<String, int> studentAbsenceCounts = {};
    for (var studentId in allStudentIds) {
      int absences = 0;
      final studentAttended = attendedEvents[studentId] ?? {};
      
      for (var eventId in eventIds) {
        if (!studentAttended.contains(eventId)) {
          absences++;
        }
      }
      
      if (absences > 0) {
        studentAbsenceCounts[studentId] = absences;
      }
    }

    // 6. For each student with absences, find the matching sanction rule and create a record
    List<Map<String, dynamic>> sanctionRecords = [];

    studentAbsenceCounts.forEach((studentId, count) {
      // Find the rule where absence_count <= count, pick the one with highest absence_count
      final matchingRule = rules
          .where((r) => (r['absence_count'] as int) <= count)
          .toList()
        ..sort((a, b) => (b['absence_count'] as int).compareTo(a['absence_count'] as int));
      
      if (matchingRule.isNotEmpty) {
        final rule = matchingRule.first;
        sanctionRecords.add({
          'student_id': studentId,
          'scope_type': scopeType,
          'scope_id': scopeId,
          'academic_term_id': termId,
          'total_absences': count,
          'required_item': rule['item_description'],
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
}
