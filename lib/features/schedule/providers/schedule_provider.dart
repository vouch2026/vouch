import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import '../repositories/schedule_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../academic_structure/providers/term_provider.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final box = Hive.box('schedules');
  return ScheduleRepository(SupabaseConfig.client, box);
});

class SchedulesNotifier extends AsyncNotifier<List<ScheduleModel>> {
  @override
  FutureOr<List<ScheduleModel>> build() async {
    final activeTermAsync = ref.watch(activeTermProvider);
    final activeTerm = activeTermAsync.valueOrNull;
    if (activeTerm == null) return [];
    
    final repository = ref.watch(scheduleRepositoryProvider);
    return repository.getSchedules(activeTerm.id);
  }

  Future<void> addSchedule({
    required String subjectCode,
    required String subjectName,
    required String teacher,
    required String startTime,
    required String endTime,
    required List<String> days,
    required String room,
  }) async {
    final activeTerm = ref.read(activeTermProvider).valueOrNull;
    if (activeTerm == null) throw Exception('No active academic term found');
    
    final repository = ref.read(scheduleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final schedule = ScheduleModel(
        subjectCode: subjectCode,
        subjectName: subjectName,
        teacher: teacher,
        startTime: startTime,
        endTime: endTime,
        days: days,
        room: room,
        academicTermId: activeTerm.id,
      );
      await repository.createSchedule(schedule);
      return repository.getSchedules(activeTerm.id);
    });
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    final activeTerm = ref.read(activeTermProvider).valueOrNull;
    if (activeTerm == null) throw Exception('No active academic term found');
    
    final repository = ref.read(scheduleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.updateSchedule(schedule);
      return repository.getSchedules(activeTerm.id);
    });
  }

  Future<void> deleteSchedule(String id) async {
    final activeTerm = ref.read(activeTermProvider).valueOrNull;
    if (activeTerm == null) throw Exception('No active academic term found');
    
    final repository = ref.read(scheduleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.deleteSchedule(id);
      return repository.getSchedules(activeTerm.id);
    });
  }

  Future<void> syncAndRefresh() async {
    final activeTerm = ref.read(activeTermProvider).valueOrNull;
    if (activeTerm == null) return;
    
    final repository = ref.read(scheduleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.syncSchedules(activeTerm.id);
      return repository.getSchedules(activeTerm.id);
    });
  }
}

final schedulesProvider = AsyncNotifierProvider<SchedulesNotifier, List<ScheduleModel>>(() {
  return SchedulesNotifier();
});
