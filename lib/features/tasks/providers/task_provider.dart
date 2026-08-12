import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/services/notification_service.dart';
import '../../settings/models/settings_model.dart';
import '../../settings/providers/settings_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = Hive.box('tasks');
  return TaskRepository(SupabaseConfig.client, box);
});

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  FutureOr<List<TaskModel>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    final tasks = await repository.getTasks();
    final settings = ref.watch(settingsProvider);
    _syncAllNotifications(tasks, settings);
    return tasks;
  }

  Future<void> addTask(String title, String description, DateTime? dueDate) async {
    final repository = ref.read(taskRepositoryProvider);
    final previousState = state;

    // Create a temporary task object with a unique temporary ID.
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempTask = TaskModel(
      id: tempId,
      title: title,
      description: description,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: kIsWeb ? 'synced' : 'to_create',
    );

    if (state.hasValue) {
      final currentList = state.value!;
      // Prepend the new task since tasks are ordered with newest first.
      final updatedList = [tempTask, ...currentList];
      state = AsyncValue.data(updatedList);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(updatedList, settings);
    }

    try {
      final createdTask = await repository.createTask(tempTask.copyWith(id: null));

      // Update state with the actual task from repository/database
      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((t) {
          if (t.id == tempId) {
            return createdTask;
          }
          return t;
        }).toList();
        state = AsyncValue.data(updatedList);
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(updatedList, settings);
      } else {
        final tasks = await repository.getTasks();
        state = AsyncValue.data(tasks);
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(tasks, settings);
      }
    } catch (e, stack) {
      // Revert state on error
      state = previousState;
      if (previousState.hasValue) {
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(previousState.value!, settings);
      }
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final repository = ref.read(taskRepositoryProvider);
    final previousState = state;

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList.map((t) {
        if (t.id == task.id) {
          return task;
        }
        return t;
      }).toList();
      state = AsyncValue.data(updatedList);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(updatedList, settings);
    }

    try {
      final updated = await repository.updateTask(task);
      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((t) {
          if (t.id == task.id) {
            return updated;
          }
          return t;
        }).toList();
        state = AsyncValue.data(updatedList);
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(updatedList, settings);
      } else {
        final tasks = await repository.getTasks();
        state = AsyncValue.data(tasks);
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(tasks, settings);
      }
    } catch (e, stack) {
      state = previousState;
      if (previousState.hasValue) {
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(previousState.value!, settings);
      }
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    final repository = ref.read(taskRepositoryProvider);
    final previousState = state;

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList.where((t) => t.id != id).toList();
      state = AsyncValue.data(updatedList);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(updatedList, settings);
    }

    try {
      await repository.deleteTask(id);
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(tasks, settings);
    } catch (e, stack) {
      state = previousState;
      if (previousState.hasValue) {
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(previousState.value!, settings);
      }
      rethrow;
    }
  }

  Future<void> deleteAllCompletedTasks() async {
    final repository = ref.read(taskRepositoryProvider);
    final previousState = state;

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList.where((t) => !t.isCompleted).toList();
      state = AsyncValue.data(updatedList);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(updatedList, settings);
    }

    try {
      final currentTasks = previousState.value ?? await repository.getTasks();
      final completedTasks = currentTasks.where((t) => t.isCompleted).toList();
      for (final task in completedTasks) {
        if (task.id != null) {
          await repository.deleteTask(task.id!);
        }
      }
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(tasks, settings);
    } catch (e, stack) {
      state = previousState;
      if (previousState.hasValue) {
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(previousState.value!, settings);
      }
      rethrow;
    }
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final repository = ref.read(taskRepositoryProvider);
    final previousState = state;

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList.map((t) {
        if (t.id == task.id) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList();
      state = AsyncValue.data(updatedList);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(updatedList, settings);
    }

    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updatedTask);
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(tasks, settings);
    } catch (e, stack) {
      state = previousState;
      if (previousState.hasValue) {
        final settings = ref.read(settingsProvider);
        _syncAllNotifications(previousState.value!, settings);
      }
      rethrow;
    }
  }

  Future<void> syncAndRefresh() async {
    final repository = ref.read(taskRepositoryProvider);
    try {
      await repository.syncTasks();
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(tasks, settings);
    } catch (e, stack) {
      if (!state.hasValue) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  void _syncAllNotifications(List<TaskModel> tasks, AppSettings settings) {
    for (final task in tasks) {
      _cancelNotification(task);
      if (settings.notificationsEnabled && !task.isCompleted && task.dueDate != null) {
        _scheduleNotification(task, settings);
      }
    }
  }

  void _scheduleNotification(TaskModel task, AppSettings settings) {
    if (task.id == null || task.dueDate == null || task.isCompleted) return;
    
    _cancelNotification(task);
    if (!settings.notificationsEnabled) return;

    final leadMinutes = settings.taskReminderLeadMinutes;
    final scheduledDate = task.dueDate!.subtract(Duration(minutes: leadMinutes));
    
    // If the scheduled reminder time is in the past, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) return;

    // Use hashcode of the ID (or generate a unique integer) for the notification ID
    final notificationId = task.id.hashCode;

    NotificationService.scheduleOneShotNotification(
      id: notificationId,
      title: 'Task Reminder: ${task.title}',
      body: 'Task "${task.title}" is due in ${_formatMinutes(leadMinutes)}.',
      scheduledDate: scheduledDate,
    );
  }

  void _cancelNotification(TaskModel task) {
    if (task.id == null) return;
    NotificationService.cancelNotification(task.id.hashCode);
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return '$days day${days > 1 ? "s" : ""}';
    } else if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return '$hours hour${hours > 1 ? "s" : ""}';
    } else {
      return '$minutes minute${minutes > 1 ? "s" : ""}';
    }
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(() {
  return TasksNotifier();
});
