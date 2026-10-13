import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_model.freezed.dart';
part 'survey_model.g.dart';

@freezed
abstract class SurveyModel with _$SurveyModel {
  const factory SurveyModel({
    String? id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'created_by_user_id') String? createdByUserId,
    @JsonKey(name: 'is_open') @Default(true) bool isOpen,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SurveyModel;

  factory SurveyModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyModelFromJson(json);
}
