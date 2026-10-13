// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SurveyModel _$SurveyModelFromJson(Map<String, dynamic> json) => _SurveyModel(
  id: json['id'] as String?,
  eventId: json['event_id'] as String,
  createdByUserId: json['created_by_user_id'] as String?,
  isOpen: json['is_open'] as bool? ?? true,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SurveyModelToJson(_SurveyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'created_by_user_id': instance.createdByUserId,
      'is_open': instance.isOpen,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
