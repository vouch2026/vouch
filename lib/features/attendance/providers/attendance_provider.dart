import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final box = Hive.box('my_scans');
  final cacheKey = 'history_$studentId';
  try {
    final history = await ref.watch(attendanceRepositoryProvider).getUserAttendanceHistory(studentId);
    await box.put(cacheKey, history);
    return history;
  } catch (e) {
    final cached = box.get(cacheKey);
    if (cached != null) {
      // Cast the dynamic list maps back
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    rethrow;
  }
});
