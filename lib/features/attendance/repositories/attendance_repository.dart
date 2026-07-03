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
    final now = DateTime.now().toUtc().toIso8601String();
    
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

    if (existing != null) {
      if (isTimeIn && existing['actual_time_in'] != null) {
        final time = DateTime.parse(existing['actual_time_in'] as String).toLocal();
        final period = time.hour >= 12 ? 'PM' : 'AM';
        final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
        final formattedTime = '$hour:${time.minute.toString().padLeft(2, '0')} $period';
        throw Exception('Student has already timed in at $formattedTime.');
      }
      if (!isTimeIn && existing['actual_time_out'] != null) {
        final time = DateTime.parse(existing['actual_time_out'] as String).toLocal();
        final period = time.hour >= 12 ? 'PM' : 'AM';
        final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
        final formattedTime = '$hour:${time.minute.toString().padLeft(2, '0')} $period';
        throw Exception('Student has already timed out at $formattedTime.');
      }
    }

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
        .select('*, student:users!student_attendance_student_id_fkey(*, program:programs!users_program_id_fkey(*))')
        .eq('event_id', eventId)
        .order('updated_at', ascending: false)
        .limit(20);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAllAttendanceForEvent(
    String eventId,
    String scopeType,
    String scopeId,
  ) async {
    String orgField;
    String orgType;
    if (scopeType == 'Institutional') {
      orgField = 'campus_id';
      orgType = 'campus-based';
    } else if (scopeType == 'Faculty') {
      orgField = 'faculty_id';
      orgType = 'faculty-based';
    } else {
      orgField = 'program_id';
      orgType = 'program-based';
    }

    final response = await _client
        .from('student_attendance')
        .select('''
          *,
          student:users!student_attendance_student_id_fkey!inner(
            *,
            program:programs!users_program_id_fkey(*, faculty:faculties(*)),
            organization_members!inner(
              status,
              role:roles!inner(name),
              organizations!inner(type, $orgField)
            )
          )
        ''')
        .eq('event_id', eventId)
        .eq('student.account_status', 'active')
        .eq('student.organization_members.status', 'active')
        .eq('student.organization_members.role.name', 'Member')
        .eq('student.organization_members.organizations.type', orgType)
        .eq('student.organization_members.organizations.$orgField', scopeId)
        .order('updated_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<int> getStudentsCountForScope(String scopeType, String scopeId) async {
    String orgField;
    String orgType;
    if (scopeType == 'Institutional') {
      orgField = 'campus_id';
      orgType = 'campus-based';
    } else if (scopeType == 'Faculty') {
      orgField = 'faculty_id';
      orgType = 'faculty-based';
    } else {
      orgField = 'program_id';
      orgType = 'program-based';
    }

    final response = await _client
        .from('organization_members')
        .select('id, user:users!inner(account_status), role:roles!inner(name), organizations:organizations!inner(type, $orgField)')
        .eq('status', 'active')
        .eq('user.account_status', 'active')
        .eq('role.name', 'Member')
        .eq('organizations.type', orgType)
        .eq('organizations.$orgField', scopeId);

    return (response as List).length;
  }
}
