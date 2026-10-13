import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey_answer_model.freezed.dart';
part 'survey_answer_model.g.dart';

@freezed
abstract class SurveyAnswerModel with _$SurveyAnswerModel {
  const factory SurveyAnswerModel({
    String? id,
    @JsonKey(name: 'response_id') required String responseId,
    @JsonKey(name: 'question_id') required String questionId,
    @JsonKey(name: 'answer_text') String? answerText,
    @JsonKey(name: 'answer_option') String? answerOption,
    @JsonKey(name: 'answer_bool') bool? answerBool,
    @JsonKey(name: 'answer_rating') int? answerRating,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _SurveyAnswerModel;

  factory SurveyAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$SurveyAnswerModelFromJson(json);
}
