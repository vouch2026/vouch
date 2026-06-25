import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_settings_history_model.g.dart';
part 'organization_settings_history_model.freezed.dart';

@freezed
abstract class OrganizationSettingsHistoryModel with _$OrganizationSettingsHistoryModel {
  const factory OrganizationSettingsHistoryModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'setting_key') required String settingKey,
    @JsonKey(name: 'old_value') dynamic oldValue,
    @JsonKey(name: 'new_value') dynamic newValue,
    @JsonKey(name: 'changed_by_user_id') String? changedByUserId,
    @JsonKey(name: 'academic_term_id') String? academicTermId,
    @JsonKey(name: 'changed_at') DateTime? changedAt,
  }) = _OrganizationSettingsHistoryModel;

  factory OrganizationSettingsHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$OrganizationSettingsHistoryModelFromJson(json);
}
