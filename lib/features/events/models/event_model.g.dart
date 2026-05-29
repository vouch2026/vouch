// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventModelImpl _$$EventModelImplFromJson(Map<String, dynamic> json) =>
    _$EventModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      shortDescription: json['short_description'] as String?,
      fullDescription: json['full_description'] as String?,
      imageUrl: json['image_url'] as String?,
      location: json['location'] as String,
      timeInStart: json['time_in_start'] as String,
      timeInEnd: json['time_in_end'] as String,
      timeOutStart: json['time_out_start'] as String,
      timeOutEnd: json['time_out_end'] as String,
      scopeType: json['scope_type'] as String,
      scopeId: json['scope_id'] as String,
      isMandatory: json['is_mandatory'] as bool? ?? true,
      academicTermId: json['academic_term_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      createdByUserId: json['created_by_user_id'] as String?,
    );

Map<String, dynamic> _$$EventModelImplToJson(_$EventModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'event_date': instance.eventDate.toIso8601String(),
      'short_description': instance.shortDescription,
      'full_description': instance.fullDescription,
      'image_url': instance.imageUrl,
      'location': instance.location,
      'time_in_start': instance.timeInStart,
      'time_in_end': instance.timeInEnd,
      'time_out_start': instance.timeOutStart,
      'time_out_end': instance.timeOutEnd,
      'scope_type': instance.scopeType,
      'scope_id': instance.scopeId,
      'is_mandatory': instance.isMandatory,
      'academic_term_id': instance.academicTermId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'created_by_user_id': instance.createdByUserId,
    };
