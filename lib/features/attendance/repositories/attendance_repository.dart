import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final SupabaseClient _client;

  AttendanceRepository(this._client);

  Future<AttendanceModel?> getUserAttendanceForEvent(String eventId, String userId) async {
    final response = await _client
        .from('student_attendance')
        .select()
        .eq('event_id', eventId)
        .eq('student_id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return AttendanceModel.fromJson(response);
  }

  Future<void> recordAttendance({
    required String eventId,
    required String studentId,
    required String scannedByUserId,
    required bool isTimeIn,
  }) async {
    final now = DateTime.now().toIso8601String();
    
    // Validate if studentId is a UUID. If not, it's likely a School ID string.
    String actualStudentUuid = studentId;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    
    if (!uuidRegex.hasMatch(studentId)) {
      final userResponse = await _client
          .from('users')
          .select('id')
          .eq('student_id_number', studentId)
          .maybeSingle();
      
      if (userResponse == null) {
        throw Exception('Student with ID $studentId not found in the database.');
      }
      actualStudentUuid = userResponse['id'];
    }

    final existing = await _client
        .from('student_attendance')
        .select()
        .eq('event_id', eventId)
        .eq('student_id', actualStudentUuid)
        .maybeSingle();

    if (existing == null) {
      await _client.from('student_attendance').insert({
        'event_id': eventId,
        'student_id': actualStudentUuid,
        'scanned_by_user_id': scannedByUserId,
        'actual_time_in': isTimeIn ? now : null,
        'actual_time_out': isTimeIn ? null : now,
        'status': 'Present',
        'updated_at': now,
      });
    } else {
      await _client.from('student_attendance').update({
        'scanned_by_user_id': scannedByUserId,
        if (isTimeIn) 'actual_time_in': now,
        if (!isTimeIn) 'actual_time_out': now,
        'status': 'Present',
        'updated_at': now,
      }).eq('id', existing['id']);
    }
  }

  Future<List<Map<String, dynamic>>> getRecentScansForEvent(String eventId) async {
    final response = await _client
        .from('student_attendance')
        .select('*, student:users(*, program:programs!users_program_id_fkey(*))')
        .eq('event_id', eventId)
        .order('updated_at', ascending: false)
        .limit(20);
    
    return List<Map<String, dynamic>>.from(response);
  }
}
