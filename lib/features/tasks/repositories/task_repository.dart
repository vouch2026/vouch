import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  final SupabaseClient _client;
  final Box _box;

  TaskRepository(this._client, this._box);

  // Helper to check network connectivity on mobile
  Future<bool> _isOnline() async {
    if (kIsWeb) return true;
    try {
      final host = Uri.parse(_client.rest.url).host;
      final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      // Fallback: let actual Supabase requests run and fail gracefully via try-catch
      return true;
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

  // Perform full two-way synchronization for mobile
  Future<void> syncTasks() async {
    if (kIsWeb) return;
    
    final userId = _getCurrentUserId();
    if (userId == null) return;

    final isOnline = await _isOnline();
    if (!isOnline) return;

    try {
      // 1. Push local changes to Supabase
      final localData = _box.values.map((v) {
        final map = Map<String, dynamic>.from(v as Map);
        return TaskModel.fromJson(map);
      }).toList();

      for (final task in localData) {
        if (task.syncStatus == 'to_create') {
          // Prepare task json for Supabase insert
          final taskJson = task.toJson();
          taskJson.remove('id');
          taskJson.remove('syncStatus');
          taskJson['user_id'] = userId;

          final response = await _client.from('tasks').insert(taskJson).select('id').single();
          
          // Update in Hive with correct Supabase ID
          final syncedTask = task.copyWith(
            id: response['id'] as String,
            syncStatus: 'synced',
          );
          await _box.delete(task.id);
          await _box.put(syncedTask.id, syncedTask.toJson());
        } 
        else if (task.syncStatus == 'to_update') {
          if (task.id == null) continue;
          
          final taskJson = task.toJson();
          taskJson.remove('syncStatus');

          await _client.from('tasks').update(taskJson).eq('id', task.id!);
          
          final syncedTask = task.copyWith(syncStatus: 'synced');
          await _box.put(task.id, syncedTask.toJson());
        } 
        else if (task.syncStatus == 'to_delete') {
          if (task.id != null && !task.id!.startsWith('local_')) {
            await _client.from('tasks').delete().eq('id', task.id!);
          }
          await _box.delete(task.id);
        }
      }

      // 2. Fetch latest tasks from Supabase
      final response = await _client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final remoteTasks = (response as List).map((json) {
        final map = Map<String, dynamic>.from(json);
        // Map created/updated timestamps if they are strings
        return TaskModel.fromJson(map).copyWith(syncStatus: 'synced');
      }).toList();

      // 3. Update Hive cache
      final remoteIds = remoteTasks.map((t) => t.id).toSet();
      
      // Delete local tasks that are marked synced but not present in remote (deleted elsewhere)
      final keysToDelete = <String>[];
      for (final key in _box.keys) {
        final taskJson = Map<String, dynamic>.from(_box.get(key) as Map);
        final task = TaskModel.fromJson(taskJson);
        if (task.syncStatus == 'synced' && !remoteIds.contains(task.id)) {
          keysToDelete.add(key as String);
        }
      }
      for (final key in keysToDelete) {
        await _box.delete(key);
      }

      // Save all remote tasks to Hive
      for (final task in remoteTasks) {
        await _box.put(task.id, task.toJson());
      }
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  // Fetch all tasks
  Future<List<TaskModel>> getTasks() async {
    final userId = _getCurrentUserId();
    if (userId == null) return [];

    if (kIsWeb) {
      // Web: Online only
      try {
        final response = await _client
            .from('tasks')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        return (response as List).map((json) => TaskModel.fromJson(Map<String, dynamic>.from(json))).toList();
      } catch (e) {
        debugPrint('Web getTasks failed: $e');
        return [];
      }
    } else {
      // Mobile: Offline first
      await syncTasks(); // Try to sync first if online
      
      return _box.values
          .map((v) => TaskModel.fromJson(Map<String, dynamic>.from(v as Map)))
          .where((task) => task.syncStatus != 'to_delete')
          .toList()
          ..sort((a, b) {
            // Sort by isCompleted ascending, then due_date/created_at descending
            if (a.isCompleted != b.isCompleted) {
              return a.isCompleted ? 1 : -1;
            }
            final aTime = a.createdAt ?? DateTime.now();
            final bTime = b.createdAt ?? DateTime.now();
            return bTime.compareTo(aTime);
          });
    }
  }

  // Create task
  Future<TaskModel> createTask(TaskModel task) async {
    final userId = _getCurrentUserId();
    final now = DateTime.now();
    
    if (kIsWeb) {
      final taskJson = task.toJson();
      taskJson.remove('id');
      taskJson.remove('syncStatus');
      taskJson['user_id'] = userId;
      taskJson['created_at'] = now.toIso8601String();
      taskJson['updated_at'] = now.toIso8601String();

      final response = await _client.from('tasks').insert(taskJson).select().single();
      return TaskModel.fromJson(Map<String, dynamic>.from(response));
    } else {
      final localId = _generateLocalId();
      final localTask = task.copyWith(
        id: localId,
        userId: userId,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'to_create',
      );

      // Save to local DB first
      await _box.put(localId, localTask.toJson());

      // Attempt to sync online immediately in the background
      final isOnline = await _isOnline();
      if (isOnline && userId != null) {
        try {
          final taskJson = localTask.toJson();
          taskJson.remove('id');
          taskJson.remove('syncStatus');
          taskJson['user_id'] = userId;

          final response = await _client.from('tasks').insert(taskJson).select('id').single();
          
          final syncedTask = localTask.copyWith(
            id: response['id'] as String,
            syncStatus: 'synced',
          );
          
          await _box.delete(localId);
          await _box.put(syncedTask.id, syncedTask.toJson());
          return syncedTask;
        } catch (e) {
          debugPrint('Immediate task creation sync failed: $e');
        }
      }
      return localTask;
    }
  }

  // Update task
  Future<TaskModel> updateTask(TaskModel task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(updatedAt: now);

    if (kIsWeb) {
      if (updatedTask.id == null) throw Exception('Cannot update task without ID');
      
      final taskJson = updatedTask.toJson();
      taskJson.remove('syncStatus');

      await _client.from('tasks').update(taskJson).eq('id', updatedTask.id!);
      return updatedTask;
    } else {
      if (updatedTask.id == null) throw Exception('Cannot update local task without ID');

      // Update sync status: if already to_create, keep to_create. Otherwise to_update.
      final currentLocal = _box.get(updatedTask.id);
      String nextSyncStatus = 'to_update';
      if (currentLocal != null) {
        final currentTask = TaskModel.fromJson(Map<String, dynamic>.from(currentLocal as Map));
        if (currentTask.syncStatus == 'to_create') {
          nextSyncStatus = 'to_create';
        }
      }

      final taskToSave = updatedTask.copyWith(syncStatus: nextSyncStatus);
      await _box.put(updatedTask.id, taskToSave.toJson());

      // Attempt to sync update online in the background
      final isOnline = await _isOnline();
      if (isOnline && nextSyncStatus == 'to_update') {
        try {
          final taskJson = taskToSave.toJson();
          taskJson.remove('syncStatus');

          await _client.from('tasks').update(taskJson).eq('id', taskToSave.id!);
          
          final syncedTask = taskToSave.copyWith(syncStatus: 'synced');
          await _box.put(updatedTask.id, syncedTask.toJson());
          return syncedTask;
        } catch (e) {
          debugPrint('Immediate task update sync failed: $e');
        }
      }
      return taskToSave;
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    if (kIsWeb) {
      await _client.from('tasks').delete().eq('id', id);
    } else {
      final currentLocal = _box.get(id);
      if (currentLocal == null) return;
      
      final currentTask = TaskModel.fromJson(Map<String, dynamic>.from(currentLocal as Map));
      
      if (currentTask.syncStatus == 'to_create') {
        // If not synced yet, delete directly
        await _box.delete(id);
      } else {
        // Mark for deletion
        final taskToDelete = currentTask.copyWith(syncStatus: 'to_delete');
        await _box.put(id, taskToDelete.toJson());

        // Attempt immediate deletion
        final isOnline = await _isOnline();
        if (isOnline) {
          try {
            await _client.from('tasks').delete().eq('id', id);
            await _box.delete(id);
          } catch (e) {
            debugPrint('Immediate task delete sync failed: $e');
          }
        }
      }
    }
  }
}
