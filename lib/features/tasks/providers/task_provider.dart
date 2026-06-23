import 'dart:async';
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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final task = TaskModel(
        title: title,
        description: description,
        dueDate: dueDate,
      );
      await repository.createTask(task);
      return repository.getTasks();
    });
  }

  Future<void> updateTask(TaskModel task) async {
    final repository = ref.read(taskRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateTask(task);
      return repository.getTasks();
    });
  }

  Future<void> deleteTask(String id) async {
    final repository = ref.read(taskRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteTask(id);
      return repository.getTasks();
    });
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final repository = ref.read(taskRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updatedTask);
      return repository.getTasks();
    });
  }

  Future<void> syncAndRefresh() async {
    final repository = ref.read(taskRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.syncTasks();
      return repository.getTasks();
    });
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskModel>>(() {
  return TasksNotifier();
});
