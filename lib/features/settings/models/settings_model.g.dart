// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
  scheduleReminderLeadMinutes:
      (json['schedule_reminder_lead_minutes'] as num?)?.toInt() ?? 15,
  taskReminderLeadMinutes:
      (json['task_reminder_lead_minutes'] as num?)?.toInt() ?? 1440,
  announcementNotifications:
      json['announcement_notifications'] as bool? ?? true,
  electionNotifications: json['election_notifications'] as bool? ?? true,
  financeNotifications: json['finance_notifications'] as bool? ?? true,
  themeMode: json['theme_mode'] as String? ?? 'system',
  biometricLockEnabled: json['biometric_lock_enabled'] as bool? ?? false,
  wifiOnlySync: json['wifi_only_sync'] as bool? ?? false,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'notifications_enabled': instance.notificationsEnabled,
      'schedule_reminder_lead_minutes': instance.scheduleReminderLeadMinutes,
      'task_reminder_lead_minutes': instance.taskReminderLeadMinutes,
      'announcement_notifications': instance.announcementNotifications,
      'election_notifications': instance.electionNotifications,
      'finance_notifications': instance.financeNotifications,
      'theme_mode': instance.themeMode,
      'biometric_lock_enabled': instance.biometricLockEnabled,
      'wifi_only_sync': instance.wifiOnlySync,
    };
