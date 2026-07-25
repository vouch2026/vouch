import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance_model.dart';
import '../repositories/attendance_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/qr_scan_ui_model.dart';
import 'package:vouch_v2/core/providers/connectivity_provider.dart';

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

Future<void> syncAllPendingScans(Ref ref) async {
  final box = Hive.box('attendance_scans');
  final repository = ref.read(attendanceRepositoryProvider);
  
  final keys = box.keys.where((k) => k.toString().startsWith('scans_')).toList();
  if (keys.isEmpty) return;
  
  for (final key in keys) {
    final cachedData = box.get(key);
    if (cachedData == null) continue;
    
    try {
      final cachedList = (cachedData as List).map((item) {
        return QrScanUIModel.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList();
      
      final pending = cachedList.where((s) => s.isPending).toList();
      if (pending.isEmpty) continue;
      
      final eventId = key.toString().replaceFirst('scans_', '');
      List<QrScanUIModel> updatedScans = List.from(cachedList);
      bool anySynced = false;
      
      for (final scan in pending) {
        if (scan.scannedByUserId == null) continue;
        try {
          await repository.recordAttendance(
            eventId: eventId,
            studentId: scan.studentUuid ?? scan.studentId,
            scannedByUserId: scan.scannedByUserId!,
            isTimeIn: scan.type == 'Time In',
          );
          
          final index = updatedScans.indexWhere((s) => s.studentId == scan.studentId && s.type == scan.type && s.isPending);
          if (index != -1) {
            updatedScans[index] = updatedScans[index].copyWith(status: 'success');
            anySynced = true;
          }
        } catch (e) {
          final isNetworkError = e.toString().contains('SocketException') || e.toString().contains('Failed host lookup') || e.toString().contains('connection') || e.toString().contains('network') || e.toString().contains('ClientException');
          if (!isNetworkError) {
            final index = updatedScans.indexWhere((s) => s.studentId == scan.studentId && s.type == scan.type && s.isPending);
            if (index != -1) {
              updatedScans.removeAt(index);
              anySynced = true;
            }
          }
          debugPrint('Sync failed for ${scan.name} in global sync: $e');
        }
      }
      
      if (anySynced) {
        await box.put(key, updatedScans.map((s) => s.toJson()).toList());
      }
    } catch (e) {
      debugPrint('Error processing global sync for key $key: $e');
    }
  }
}

final globalSyncProvider = Provider((ref) {
  Future.microtask(() => syncAllPendingScans(ref));

  ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
    if (next.value == true && previous?.value != true) {
      debugPrint('Internet recovered: triggering global offline sync...');
      syncAllPendingScans(ref);
    }
  });
  return null;
});
