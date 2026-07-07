import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../../../core/config/supabase_config.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final box = Hive.box('tasks');
  return TaskRepository(SupabaseConfig.client, box);
});

class TasksNotifier extends AsyncNotifier<List<TaskModel>> {
  @override
  FutureOr<List<TaskModel>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getTasks();
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
      state = AsyncValue.data([tempTask, ...currentList]);
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
      } else {
        final tasks = await repository.getTasks();
        state = AsyncValue.data(tasks);
      }
    } catch (e, stack) {
      // Revert state on error
      state = previousState;
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
      } else {
        final tasks = await repository.getTasks();
        state = AsyncValue.data(tasks);
      }
    } catch (e, stack) {
      state = previousState;
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
    }

    try {
      await repository.deleteTask(id);
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = previousState;
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
    } catch (e, stack) {
      state = previousState;
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
    }

    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updatedTask);
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> syncAndRefresh() async {
    final repository = ref.read(taskRepositoryProvider);
    try {
      await repository.syncTasks();
      final tasks = await repository.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      if (!state.hasValue) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(() {
  return TasksNotifier();
});
