import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import '../repositories/schedule_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../settings/models/settings_model.dart';
import '../../settings/providers/settings_provider.dart';

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
    
    final settings = ref.watch(settingsProvider);
    
    final repository = ref.watch(scheduleRepositoryProvider);
    final schedules = await repository.getSchedules(activeTerm.id);
    _syncAllNotifications(schedules, settings);
    return schedules;
  }

  Future<void> addSchedule({
    required String subjectCode,
    required String subjectName,
    required String teacher,
    required String startTime,
    required String endTime,
    required List<String> days,
    required String room,
    int reminderMinutes = 0,
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
        reminderMinutes: reminderMinutes,
      );
      final created = await repository.createSchedule(schedule);
      final settings = ref.read(settingsProvider);
      _scheduleNotifications(created, settings);
      return repository.getSchedules(activeTerm.id);
    });
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    final activeTerm = ref.read(activeTermProvider).valueOrNull;
    if (activeTerm == null) throw Exception('No active academic term found');
    
    final repository = ref.read(scheduleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await repository.updateSchedule(schedule);
      final settings = ref.read(settingsProvider);
      _scheduleNotifications(updated, settings);
      return repository.getSchedules(activeTerm.id);
    });
  }

  Future<void> deleteSchedule(String id) async {
    final activeTerm = ref.read(activeTermProvider).valueOrNull;
    if (activeTerm == null) throw Exception('No active academic term found');
    
    final repository = ref.read(scheduleRepositoryProvider);
    
    // Find the schedule to cancel its notifications
    final schedules = state.valueOrNull ?? [];
    final scheduleToDelete = schedules.firstWhere((s) => s.id == id, orElse: () => const ScheduleModel(
      subjectCode: '',
      subjectName: '',
      startTime: '',
      endTime: '',
      days: [],
      academicTermId: '',
    ));
    _cancelNotifications(scheduleToDelete);

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
      final schedules = await repository.getSchedules(activeTerm.id);
      final settings = ref.read(settingsProvider);
      _syncAllNotifications(schedules, settings);
      return schedules;
    });
  }

  void _syncAllNotifications(List<ScheduleModel> schedules, AppSettings settings) {
    for (final schedule in schedules) {
      _cancelNotifications(schedule);
      if (settings.notificationsEnabled) {
        _scheduleNotifications(schedule, settings);
      }
    }
  }

  void _scheduleNotifications(ScheduleModel schedule, AppSettings settings) {
    if (schedule.id == null) return;
    
    _cancelNotifications(schedule);
    if (!settings.notificationsEnabled) return;

    final leadMinutes = settings.scheduleReminderLeadMinutes;
    if (leadMinutes <= 0) return;

    final baseId = schedule.id.hashCode;
    for (final day in schedule.days) {
      final weekday = _getDayOfWeekIndex(day);
      final notificationId = baseId + weekday;

      NotificationService.scheduleWeeklyNotification(
        id: notificationId,
        title: '${schedule.subjectCode}: ${schedule.subjectName}',
        body: 'Class starts in $leadMinutes minutes (${schedule.startTime} - ${schedule.endTime}) at ${schedule.room.isNotEmpty ? schedule.room : "your room"}.',
        dayOfWeek: day,
        timeStr: schedule.startTime,
        offsetMinutes: leadMinutes,
      );
    }
  }

  void _cancelNotifications(ScheduleModel schedule) {
    if (schedule.id == null) return;
    final baseId = schedule.id.hashCode;
    for (int weekday = 1; weekday <= 7; weekday++) {
      NotificationService.cancelNotification(baseId + weekday);
    }
  }

  int _getDayOfWeekIndex(String day) {
    switch (day.toLowerCase()) {
      case 'monday': return 1;
      case 'tuesday': return 2;
      case 'wednesday': return 3;
      case 'thursday': return 4;
      case 'friday': return 5;
      case 'saturday': return 6;
      case 'sunday': return 7;
      default: return 1;
    }
  }
}

final schedulesProvider = AsyncNotifierProvider<SchedulesNotifier, List<ScheduleModel>>(() {
  return SchedulesNotifier();
});
