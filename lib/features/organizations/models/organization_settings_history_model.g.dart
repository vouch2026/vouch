// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_settings_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationSettingsHistoryModel _$OrganizationSettingsHistoryModelFromJson(
  Map<String, dynamic> json,
) => _OrganizationSettingsHistoryModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  settingKey: json['setting_key'] as String,
  oldValue: json['old_value'],
  newValue: json['new_value'],
  changedByUserId: json['changed_by_user_id'] as String?,
  academicTermId: json['academic_term_id'] as String?,
  changedAt: json['changed_at'] == null
      ? null
      : DateTime.parse(json['changed_at'] as String),
);

Map<String, dynamic> _$OrganizationSettingsHistoryModelToJson(
  _OrganizationSettingsHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'setting_key': instance.settingKey,
  'old_value': instance.oldValue,
  'new_value': instance.newValue,
  'changed_by_user_id': instance.changedByUserId,
  'academic_term_id': instance.academicTermId,
  'changed_at': instance.changedAt?.toIso8601String(),
};
