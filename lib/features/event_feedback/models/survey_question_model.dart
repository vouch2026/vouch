import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_question_model.freezed.dart';
part 'survey_question_model.g.dart';

@freezed
abstract class SurveyQuestionModel with _$SurveyQuestionModel {
  const factory SurveyQuestionModel({
    String? id,
    @JsonKey(name: 'survey_id') required String surveyId,
    @JsonKey(name: 'question_text') required String questionText,
    @JsonKey(name: 'question_type') required String questionType,
    @Default([]) List<String> options,
    @JsonKey(name: 'is_required') @Default(true) bool isRequired,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SurveyQuestionModel;

  factory SurveyQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyQuestionModelFromJson(json);
}
