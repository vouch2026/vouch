import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final SupabaseClient _client;
  final Box _box;

  ScheduleRepository(this._client, this._box);

  // Helper to check network connectivity on mobile
  Future<bool> _isOnline() async {
    if (kIsWeb) return true;
    try {
      final host = Uri.parse(_client.rest.url).host;
      final result = await InternetAddress.lookup(host).timeout(const Duration(milliseconds: 800));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Generate a unique local ID
  String _generateLocalId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randVal = random.nextInt(1000000);
    return 'local_${timestamp}_$randVal';
  }

  // Get current user ID
  String? _getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  // Perform full two-way synchronization for mobile schedules
  Future<void> syncSchedules(String academicTermId) async {
    if (kIsWeb) return;
    
    final userId = _getCurrentUserId();
    if (userId == null) return;

    final isOnline = await _isOnline();
    if (!isOnline) return;

    try {
      // 1. Push local changes to Supabase
      final localData = _box.values.map((v) {
        final map = Map<String, dynamic>.from(v as Map);
        return ScheduleModel.fromJson(map);
      }).where((s) => s.academicTermId == academicTermId).toList();

      for (final schedule in localData) {
        if (schedule.syncStatus == 'to_create') {
          final scheduleJson = schedule.toJson();
          scheduleJson.remove('id');
          scheduleJson.remove('syncStatus');
          scheduleJson.remove('reminder_minutes');
          scheduleJson['user_id'] = userId;

          final response = await _client.from('subject_schedules').insert(scheduleJson).select('id').single();
          
          final syncedSchedule = schedule.copyWith(
            id: response['id'] as String,
            syncStatus: 'synced',
          );
          await _box.delete(schedule.id);
          await _box.put(syncedSchedule.id, syncedSchedule.toJson());
        } 
        else if (schedule.syncStatus == 'to_update') {
          if (schedule.id == null) continue;
          
          final scheduleJson = schedule.toJson();
          scheduleJson.remove('syncStatus');
          scheduleJson.remove('reminder_minutes');

          await _client.from('subject_schedules').update(scheduleJson).eq('id', schedule.id!);
          
          final syncedSchedule = schedule.copyWith(syncStatus: 'synced');
          await _box.put(schedule.id, syncedSchedule.toJson());
        } 
        else if (schedule.syncStatus == 'to_delete') {
          if (schedule.id != null && !schedule.id!.startsWith('local_')) {
            await _client.from('subject_schedules').delete().eq('id', schedule.id!);
          }
          await _box.delete(schedule.id);
        }
      }

      // 2. Fetch latest schedules from Supabase for this term
      final response = await _client
          .from('subject_schedules')
          .select()
          .eq('user_id', userId)
          .eq('academic_term_id', academicTermId);

      final remoteSchedules = (response as List).map((json) {
        final map = Map<String, dynamic>.from(json);
        // Map days to a list of strings
        if (map['days'] != null) {
          map['days'] = List<String>.from(map['days'] as List);
        }
        return ScheduleModel.fromJson(map).copyWith(syncStatus: 'synced');
      }).toList();

      // 3. Update Hive cache
      final remoteIds = remoteSchedules.map((s) => s.id).toSet();
      
      // Delete local schedules for this term that are marked synced but not present in remote
      final keysToDelete = <String>[];
      for (final key in _box.keys) {
        final scheduleJson = Map<String, dynamic>.from(_box.get(key) as Map);
        final schedule = ScheduleModel.fromJson(scheduleJson);
        if (schedule.academicTermId == academicTermId &&
            schedule.syncStatus == 'synced' &&
            !remoteIds.contains(schedule.id)) {
          keysToDelete.add(key as String);
        }
      }
      for (final key in keysToDelete) {
        await _box.delete(key);
      }

      // Save all remote schedules to Hive
      for (final schedule in remoteSchedules) {
        await _box.put(schedule.id, schedule.toJson());
      }
    } catch (e) {
      debugPrint('Schedule sync failed: $e');
    }
  }

  // Fetch all schedules for the specified academic term
  Future<List<ScheduleModel>> getSchedules(String academicTermId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return [];

    if (kIsWeb) {
      // Web: Online only
      try {
        final response = await _client
            .from('subject_schedules')
            .select()
            .eq('user_id', userId)
            .eq('academic_term_id', academicTermId)
            .timeout(const Duration(seconds: 3));
        return (response as List).map((json) {
          final map = Map<String, dynamic>.from(json);
          if (map['days'] != null) {
            map['days'] = List<String>.from(map['days'] as List);
          }
          return ScheduleModel.fromJson(map);
        }).toList();
      } catch (e) {
        debugPrint('Web getSchedules failed: $e');
        return [];
      }
    } else {
      // Mobile: Offline first, load instantly from Hive and sync in the background
      _triggerBackgroundSync(academicTermId);
      
      return _box.values
          .map((v) => ScheduleModel.fromJson(Map<String, dynamic>.from(v as Map)))
          .where((s) => s.academicTermId == academicTermId && s.syncStatus != 'to_delete')
          .toList();
    }
  }

  void _triggerBackgroundSync(String academicTermId) {
    Future.microtask(() async {
      final online = await _isOnline();
      if (online) {
        await syncSchedules(academicTermId);
      }
    });
  }

  // Create schedule
  Future<ScheduleModel> createSchedule(ScheduleModel schedule) async {
    final userId = _getCurrentUserId();
    final now = DateTime.now();
    
    if (kIsWeb) {
      final scheduleJson = schedule.toJson();
      scheduleJson.remove('id');
      scheduleJson.remove('syncStatus');
      scheduleJson.remove('reminder_minutes');
      scheduleJson['user_id'] = userId;
      scheduleJson['created_at'] = now.toIso8601String();
      scheduleJson['updated_at'] = now.toIso8601String();

      final response = await _client.from('subject_schedules').insert(scheduleJson).select().single();
      final map = Map<String, dynamic>.from(response);
      if (map['days'] != null) {
        map['days'] = List<String>.from(map['days'] as List);
      }
      return ScheduleModel.fromJson(map);
    } else {
      final localId = _generateLocalId();
      final localSchedule = schedule.copyWith(
        id: localId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'to_create',
      );

      // Save to local DB first
      await _box.put(localId, localSchedule.toJson());

      // Attempt to sync online immediately in background
      final isOnline = await _isOnline();
      if (isOnline && userId != null) {
        try {
          final scheduleJson = localSchedule.toJson();
          scheduleJson.remove('id');
          scheduleJson.remove('syncStatus');
          scheduleJson.remove('reminder_minutes');
          scheduleJson['user_id'] = userId;

          final response = await _client.from('subject_schedules').insert(scheduleJson).select('id').single();
          
          final syncedSchedule = localSchedule.copyWith(
            id: response['id'] as String,
            syncStatus: 'synced',
          );
          
          await _box.delete(localId);
          await _box.put(syncedSchedule.id, syncedSchedule.toJson());
          return syncedSchedule;
        } catch (e) {
          debugPrint('Immediate schedule creation sync failed: $e');
        }
      }
      return localSchedule;
    }
  }

  // Update schedule
  Future<ScheduleModel> updateSchedule(ScheduleModel schedule) async {
    final now = DateTime.now();
    final updatedSchedule = schedule.copyWith(updatedAt: now);

    if (kIsWeb) {
      if (updatedSchedule.id == null) throw Exception('Cannot update schedule without ID');
      
      final scheduleJson = updatedSchedule.toJson();
      scheduleJson.remove('syncStatus');
      scheduleJson.remove('reminder_minutes');

      await _client.from('subject_schedules').update(scheduleJson).eq('id', updatedSchedule.id!);
      return updatedSchedule;
    } else {
      if (updatedSchedule.id == null) throw Exception('Cannot update local schedule without ID');

      // Update sync status: if already to_create, keep to_create. Otherwise to_update.
      final currentLocal = _box.get(updatedSchedule.id);
      String nextSyncStatus = 'to_update';
      if (currentLocal != null) {
        final currentSchedule = ScheduleModel.fromJson(Map<String, dynamic>.from(currentLocal as Map));
        if (currentSchedule.syncStatus == 'to_create') {
          nextSyncStatus = 'to_create';
        }
      }

      final scheduleToSave = updatedSchedule.copyWith(syncStatus: nextSyncStatus);
      await _box.put(updatedSchedule.id, scheduleToSave.toJson());

      // Attempt to sync update online in background
      final isOnline = await _isOnline();
      if (isOnline && nextSyncStatus == 'to_update') {
        try {
          final scheduleJson = scheduleToSave.toJson();
          scheduleJson.remove('syncStatus');
          scheduleJson.remove('reminder_minutes');

          await _client.from('subject_schedules').update(scheduleJson).eq('id', scheduleToSave.id!);
          
          final syncedSchedule = scheduleToSave.copyWith(syncStatus: 'synced');
          await _box.put(updatedSchedule.id, syncedSchedule.toJson());
          return syncedSchedule;
        } catch (e) {
          debugPrint('Immediate schedule update sync failed: $e');
        }
      }
      return scheduleToSave;
    }
  }

  // Delete schedule
  Future<void> deleteSchedule(String id) async {
    if (kIsWeb) {
      await _client.from('subject_schedules').delete().eq('id', id);
    } else {
      final currentLocal = _box.get(id);
      if (currentLocal == null) return;
      
      final currentSchedule = ScheduleModel.fromJson(Map<String, dynamic>.from(currentLocal as Map));
      
      if (currentSchedule.syncStatus == 'to_create') {
        // If not synced yet, delete directly
        await _box.delete(id);
      } else {
        // Mark for deletion
        final scheduleToDelete = currentSchedule.copyWith(syncStatus: 'to_delete');
        await _box.put(id, scheduleToDelete.toJson());

        // Attempt immediate deletion
        final isOnline = await _isOnline();
        if (isOnline) {
          try {
            await _client.from('subject_schedules').delete().eq('id', id);
            await _box.delete(id);
          } catch (e) {
            debugPrint('Immediate schedule delete sync failed: $e');
          }
        }
      }
    }
  }
}
