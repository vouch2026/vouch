import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../repositories/settings_repository.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final box = Hive.box('settings');
  return SettingsService(box);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsRepository(SupabaseConfig.client, service);
});

class SettingsNotifier extends Notifier<AppSettings> {
  late final SettingsRepository _repository;

  @override
  AppSettings build() {
    _repository = ref.watch(settingsRepositoryProvider);
    // Trigger remote sync in the background
    _repository.syncSettings().then((_) {
      state = _repository.getSettings();
    });
    return _repository.getSettings();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = newSettings;
    await _repository.saveSettings(newSettings);
  }

  Future<void> updateThemeMode(String mode) async {
    final newSettings = state.copyWith(themeMode: mode);
    await updateSettings(newSettings);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final newSettings = state.copyWith(notificationsEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateScheduleReminderMinutes(int minutes) async {
    final newSettings = state.copyWith(scheduleReminderLeadMinutes: minutes);
    await updateSettings(newSettings);
  }

  Future<void> updateTaskReminderMinutes(int minutes) async {
    final newSettings = state.copyWith(taskReminderLeadMinutes: minutes);
    await updateSettings(newSettings);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});
