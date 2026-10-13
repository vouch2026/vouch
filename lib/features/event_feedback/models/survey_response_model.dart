import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_response_model.freezed.dart';
part 'survey_response_model.g.dart';

@freezed
abstract class SurveyResponseModel with _$SurveyResponseModel {
  const factory SurveyResponseModel({
    String? id,
    @JsonKey(name: 'survey_id') String? surveyId,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'overall_rating') required int overallRating,
    String? comment,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _SurveyResponseModel;

  factory SurveyResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyResponseModelFromJson(json);
}
