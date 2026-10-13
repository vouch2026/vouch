// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurveyQuestionModel _$SurveyQuestionModelFromJson(Map<String, dynamic> json) =>
    _SurveyQuestionModel(
      id: json['id'] as String?,
      surveyId: json['survey_id'] as String,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isRequired: json['is_required'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SurveyQuestionModelToJson(
  _SurveyQuestionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'survey_id': instance.surveyId,
  'question_text': instance.questionText,
  'question_type': instance.questionType,
  'options': instance.options,
  'is_required': instance.isRequired,
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt?.toIso8601String(),
};
