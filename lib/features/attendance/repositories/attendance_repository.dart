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
}
