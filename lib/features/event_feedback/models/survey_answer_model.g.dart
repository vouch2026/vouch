// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurveyAnswerModel _$SurveyAnswerModelFromJson(Map<String, dynamic> json) =>
    _SurveyAnswerModel(
      id: json['id'] as String?,
      responseId: json['response_id'] as String,
      questionId: json['question_id'] as String,
      answerText: json['answer_text'] as String?,
      answerOption: json['answer_option'] as String?,
      answerBool: json['answer_bool'] as bool?,
      answerRating: (json['answer_rating'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SurveyAnswerModelToJson(_SurveyAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'response_id': instance.responseId,
      'question_id': instance.questionId,
      'answer_text': instance.answerText,
      'answer_option': instance.answerOption,
      'answer_bool': instance.answerBool,
      'answer_rating': instance.answerRating,
      'created_at': instance.createdAt?.toIso8601String(),
    };
