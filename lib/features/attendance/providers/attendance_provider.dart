import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(SupabaseConfig.client);
});

final userEventAttendanceProvider = FutureProvider.family<AttendanceModel?, String>((ref, eventId) async {
  final user = ref.watch(userProfileProvider).value;
  if (user == null || user.id == null) return null;
  
  return ref.watch(attendanceRepositoryProvider).getUserAttendanceForEvent(eventId, user.id!);
});

final userAttendanceHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  return ref.watch(attendanceRepositoryProvider).getUserAttendanceHistory(studentId);
});
