import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @JsonKey(name: 'notifications_enabled') @Default(true) bool notificationsEnabled,
    @JsonKey(name: 'schedule_reminder_lead_minutes') @Default(15) int scheduleReminderLeadMinutes,
    @JsonKey(name: 'task_reminder_lead_minutes') @Default(1440) int taskReminderLeadMinutes,
    @JsonKey(name: 'announcement_notifications') @Default(true) bool announcementNotifications,
    @JsonKey(name: 'election_notifications') @Default(true) bool electionNotifications,
    @JsonKey(name: 'finance_notifications') @Default(true) bool financeNotifications,
    @JsonKey(name: 'theme_mode') @Default('system') String themeMode,
    @JsonKey(name: 'biometric_lock_enabled') @Default(false) bool biometricLockEnabled,
    @JsonKey(name: 'wifi_only_sync') @Default(false) bool wifiOnlySync,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
