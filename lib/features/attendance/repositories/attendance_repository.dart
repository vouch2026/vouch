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
    
    final existing = await _client
        .from('student_attendance')
        .select()
        .eq('event_id', eventId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existing == null) {
      await _client.from('student_attendance').insert({
        'event_id': eventId,
        'student_id': studentId,
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
}
