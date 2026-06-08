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

  /// Fetches personal sanction records for a student in a specific workspace and term.
  Future<List<SanctionModel>> getMySanctions(String studentId, String scopeId, String termId) async {
    final response = await _client
        .from('student_sanction_records')
        .select('''
          *,
          received_by:users!received_by_user_id (first_name, last_name)
        ''')
        .eq('student_id', studentId)
        .eq('scope_id', scopeId)
        .eq('academic_term_id', termId)
        .order('updated_at', ascending: false);
    
    return (response as List).map((json) {
      final receivedBy = json['received_by'];
      return SanctionModel.fromJson({
        ...json,
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

    // 3. Identify students with absences
    // We count absences per student for the specified events
    final attendanceResponse = await _client
        .from('student_attendance')
        .select('student_id')
        .filter('event_id', 'in', eventIds)
        .eq('status', 'Absent');
    
    final Map<String, int> studentAbsences = {};
    for (var row in attendanceResponse as List) {
      final studentId = row['student_id'] as String;
      studentAbsences[studentId] = (studentAbsences[studentId] ?? 0) + 1;
    }

    // 4. For each student, find the matching sanction rule and create a record
    List<Map<String, dynamic>> sanctionRecords = [];

    studentAbsences.forEach((studentId, count) {
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
      // Using student_id, scope_id, academic_term_id as the conflict target
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
