// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurveyResponseModel _$SurveyResponseModelFromJson(Map<String, dynamic> json) =>
    _SurveyResponseModel(
      id: json['id'] as String?,
      surveyId: json['survey_id'] as String?,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      overallRating: (json['overall_rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SurveyResponseModelToJson(
  _SurveyResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'survey_id': instance.surveyId,
  'event_id': instance.eventId,
  'user_id': instance.userId,
  'overall_rating': instance.overallRating,
  'comment': instance.comment,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
