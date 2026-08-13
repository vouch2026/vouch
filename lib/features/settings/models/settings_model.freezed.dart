// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

@JsonKey(name: 'notifications_enabled') bool get notificationsEnabled;@JsonKey(name: 'schedule_reminder_lead_minutes') int get scheduleReminderLeadMinutes;@JsonKey(name: 'task_reminder_lead_minutes') int get taskReminderLeadMinutes;@JsonKey(name: 'announcement_notifications') bool get announcementNotifications;@JsonKey(name: 'election_notifications') bool get electionNotifications;@JsonKey(name: 'finance_notifications') bool get financeNotifications;@JsonKey(name: 'theme_mode') String get themeMode;@JsonKey(name: 'biometric_lock_enabled') bool get biometricLockEnabled;@JsonKey(name: 'wifi_only_sync') bool get wifiOnlySync;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.scheduleReminderLeadMinutes, scheduleReminderLeadMinutes) || other.scheduleReminderLeadMinutes == scheduleReminderLeadMinutes)&&(identical(other.taskReminderLeadMinutes, taskReminderLeadMinutes) || other.taskReminderLeadMinutes == taskReminderLeadMinutes)&&(identical(other.announcementNotifications, announcementNotifications) || other.announcementNotifications == announcementNotifications)&&(identical(other.electionNotifications, electionNotifications) || other.electionNotifications == electionNotifications)&&(identical(other.financeNotifications, financeNotifications) || other.financeNotifications == financeNotifications)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.biometricLockEnabled, biometricLockEnabled) || other.biometricLockEnabled == biometricLockEnabled)&&(identical(other.wifiOnlySync, wifiOnlySync) || other.wifiOnlySync == wifiOnlySync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,scheduleReminderLeadMinutes,taskReminderLeadMinutes,announcementNotifications,electionNotifications,financeNotifications,themeMode,biometricLockEnabled,wifiOnlySync);

@override
String toString() {
  return 'AppSettings(notificationsEnabled: $notificationsEnabled, scheduleReminderLeadMinutes: $scheduleReminderLeadMinutes, taskReminderLeadMinutes: $taskReminderLeadMinutes, announcementNotifications: $announcementNotifications, electionNotifications: $electionNotifications, financeNotifications: $financeNotifications, themeMode: $themeMode, biometricLockEnabled: $biometricLockEnabled, wifiOnlySync: $wifiOnlySync)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'notifications_enabled') bool notificationsEnabled,@JsonKey(name: 'schedule_reminder_lead_minutes') int scheduleReminderLeadMinutes,@JsonKey(name: 'task_reminder_lead_minutes') int taskReminderLeadMinutes,@JsonKey(name: 'announcement_notifications') bool announcementNotifications,@JsonKey(name: 'election_notifications') bool electionNotifications,@JsonKey(name: 'finance_notifications') bool financeNotifications,@JsonKey(name: 'theme_mode') String themeMode,@JsonKey(name: 'biometric_lock_enabled') bool biometricLockEnabled,@JsonKey(name: 'wifi_only_sync') bool wifiOnlySync
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notificationsEnabled = null,Object? scheduleReminderLeadMinutes = null,Object? taskReminderLeadMinutes = null,Object? announcementNotifications = null,Object? electionNotifications = null,Object? financeNotifications = null,Object? themeMode = null,Object? biometricLockEnabled = null,Object? wifiOnlySync = null,}) {
  return _then(_self.copyWith(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,scheduleReminderLeadMinutes: null == scheduleReminderLeadMinutes ? _self.scheduleReminderLeadMinutes : scheduleReminderLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,taskReminderLeadMinutes: null == taskReminderLeadMinutes ? _self.taskReminderLeadMinutes : taskReminderLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,announcementNotifications: null == announcementNotifications ? _self.announcementNotifications : announcementNotifications // ignore: cast_nullable_to_non_nullable
as bool,electionNotifications: null == electionNotifications ? _self.electionNotifications : electionNotifications // ignore: cast_nullable_to_non_nullable
as bool,financeNotifications: null == financeNotifications ? _self.financeNotifications : financeNotifications // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,biometricLockEnabled: null == biometricLockEnabled ? _self.biometricLockEnabled : biometricLockEnabled // ignore: cast_nullable_to_non_nullable
as bool,wifiOnlySync: null == wifiOnlySync ? _self.wifiOnlySync : wifiOnlySync // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'schedule_reminder_lead_minutes')  int scheduleReminderLeadMinutes, @JsonKey(name: 'task_reminder_lead_minutes')  int taskReminderLeadMinutes, @JsonKey(name: 'announcement_notifications')  bool announcementNotifications, @JsonKey(name: 'election_notifications')  bool electionNotifications, @JsonKey(name: 'finance_notifications')  bool financeNotifications, @JsonKey(name: 'theme_mode')  String themeMode, @JsonKey(name: 'biometric_lock_enabled')  bool biometricLockEnabled, @JsonKey(name: 'wifi_only_sync')  bool wifiOnlySync)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.scheduleReminderLeadMinutes,_that.taskReminderLeadMinutes,_that.announcementNotifications,_that.electionNotifications,_that.financeNotifications,_that.themeMode,_that.biometricLockEnabled,_that.wifiOnlySync);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'schedule_reminder_lead_minutes')  int scheduleReminderLeadMinutes, @JsonKey(name: 'task_reminder_lead_minutes')  int taskReminderLeadMinutes, @JsonKey(name: 'announcement_notifications')  bool announcementNotifications, @JsonKey(name: 'election_notifications')  bool electionNotifications, @JsonKey(name: 'finance_notifications')  bool financeNotifications, @JsonKey(name: 'theme_mode')  String themeMode, @JsonKey(name: 'biometric_lock_enabled')  bool biometricLockEnabled, @JsonKey(name: 'wifi_only_sync')  bool wifiOnlySync)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.notificationsEnabled,_that.scheduleReminderLeadMinutes,_that.taskReminderLeadMinutes,_that.announcementNotifications,_that.electionNotifications,_that.financeNotifications,_that.themeMode,_that.biometricLockEnabled,_that.wifiOnlySync);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'notifications_enabled')  bool notificationsEnabled, @JsonKey(name: 'schedule_reminder_lead_minutes')  int scheduleReminderLeadMinutes, @JsonKey(name: 'task_reminder_lead_minutes')  int taskReminderLeadMinutes, @JsonKey(name: 'announcement_notifications')  bool announcementNotifications, @JsonKey(name: 'election_notifications')  bool electionNotifications, @JsonKey(name: 'finance_notifications')  bool financeNotifications, @JsonKey(name: 'theme_mode')  String themeMode, @JsonKey(name: 'biometric_lock_enabled')  bool biometricLockEnabled, @JsonKey(name: 'wifi_only_sync')  bool wifiOnlySync)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.scheduleReminderLeadMinutes,_that.taskReminderLeadMinutes,_that.announcementNotifications,_that.electionNotifications,_that.financeNotifications,_that.themeMode,_that.biometricLockEnabled,_that.wifiOnlySync);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({@JsonKey(name: 'notifications_enabled') this.notificationsEnabled = true, @JsonKey(name: 'schedule_reminder_lead_minutes') this.scheduleReminderLeadMinutes = 15, @JsonKey(name: 'task_reminder_lead_minutes') this.taskReminderLeadMinutes = 1440, @JsonKey(name: 'announcement_notifications') this.announcementNotifications = true, @JsonKey(name: 'election_notifications') this.electionNotifications = true, @JsonKey(name: 'finance_notifications') this.financeNotifications = true, @JsonKey(name: 'theme_mode') this.themeMode = 'system', @JsonKey(name: 'biometric_lock_enabled') this.biometricLockEnabled = false, @JsonKey(name: 'wifi_only_sync') this.wifiOnlySync = false});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey(name: 'notifications_enabled') final  bool notificationsEnabled;
@override@JsonKey(name: 'schedule_reminder_lead_minutes') final  int scheduleReminderLeadMinutes;
@override@JsonKey(name: 'task_reminder_lead_minutes') final  int taskReminderLeadMinutes;
@override@JsonKey(name: 'announcement_notifications') final  bool announcementNotifications;
@override@JsonKey(name: 'election_notifications') final  bool electionNotifications;
@override@JsonKey(name: 'finance_notifications') final  bool financeNotifications;
@override@JsonKey(name: 'theme_mode') final  String themeMode;
@override@JsonKey(name: 'biometric_lock_enabled') final  bool biometricLockEnabled;
@override@JsonKey(name: 'wifi_only_sync') final  bool wifiOnlySync;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.scheduleReminderLeadMinutes, scheduleReminderLeadMinutes) || other.scheduleReminderLeadMinutes == scheduleReminderLeadMinutes)&&(identical(other.taskReminderLeadMinutes, taskReminderLeadMinutes) || other.taskReminderLeadMinutes == taskReminderLeadMinutes)&&(identical(other.announcementNotifications, announcementNotifications) || other.announcementNotifications == announcementNotifications)&&(identical(other.electionNotifications, electionNotifications) || other.electionNotifications == electionNotifications)&&(identical(other.financeNotifications, financeNotifications) || other.financeNotifications == financeNotifications)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.biometricLockEnabled, biometricLockEnabled) || other.biometricLockEnabled == biometricLockEnabled)&&(identical(other.wifiOnlySync, wifiOnlySync) || other.wifiOnlySync == wifiOnlySync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,scheduleReminderLeadMinutes,taskReminderLeadMinutes,announcementNotifications,electionNotifications,financeNotifications,themeMode,biometricLockEnabled,wifiOnlySync);

@override
String toString() {
  return 'AppSettings(notificationsEnabled: $notificationsEnabled, scheduleReminderLeadMinutes: $scheduleReminderLeadMinutes, taskReminderLeadMinutes: $taskReminderLeadMinutes, announcementNotifications: $announcementNotifications, electionNotifications: $electionNotifications, financeNotifications: $financeNotifications, themeMode: $themeMode, biometricLockEnabled: $biometricLockEnabled, wifiOnlySync: $wifiOnlySync)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'notifications_enabled') bool notificationsEnabled,@JsonKey(name: 'schedule_reminder_lead_minutes') int scheduleReminderLeadMinutes,@JsonKey(name: 'task_reminder_lead_minutes') int taskReminderLeadMinutes,@JsonKey(name: 'announcement_notifications') bool announcementNotifications,@JsonKey(name: 'election_notifications') bool electionNotifications,@JsonKey(name: 'finance_notifications') bool financeNotifications,@JsonKey(name: 'theme_mode') String themeMode,@JsonKey(name: 'biometric_lock_enabled') bool biometricLockEnabled,@JsonKey(name: 'wifi_only_sync') bool wifiOnlySync
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notificationsEnabled = null,Object? scheduleReminderLeadMinutes = null,Object? taskReminderLeadMinutes = null,Object? announcementNotifications = null,Object? electionNotifications = null,Object? financeNotifications = null,Object? themeMode = null,Object? biometricLockEnabled = null,Object? wifiOnlySync = null,}) {
  return _then(_AppSettings(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,scheduleReminderLeadMinutes: null == scheduleReminderLeadMinutes ? _self.scheduleReminderLeadMinutes : scheduleReminderLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,taskReminderLeadMinutes: null == taskReminderLeadMinutes ? _self.taskReminderLeadMinutes : taskReminderLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,announcementNotifications: null == announcementNotifications ? _self.announcementNotifications : announcementNotifications // ignore: cast_nullable_to_non_nullable
as bool,electionNotifications: null == electionNotifications ? _self.electionNotifications : electionNotifications // ignore: cast_nullable_to_non_nullable
as bool,financeNotifications: null == financeNotifications ? _self.financeNotifications : financeNotifications // ignore: cast_nullable_to_non_nullable
as bool,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,biometricLockEnabled: null == biometricLockEnabled ? _self.biometricLockEnabled : biometricLockEnabled // ignore: cast_nullable_to_non_nullable
as bool,wifiOnlySync: null == wifiOnlySync ? _self.wifiOnlySync : wifiOnlySync // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
