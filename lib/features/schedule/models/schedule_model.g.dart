// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    _ScheduleModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      subjectCode: json['subject_code'] as String,
      subjectName: json['subject_name'] as String,
      teacher: json['teacher'] as String? ?? '',
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      days: (json['days'] as List<dynamic>).map((e) => e as String).toList(),
      room: json['room'] as String? ?? '',
      academicTermId: json['academic_term_id'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'synced',
    );

Map<String, dynamic> _$ScheduleModelToJson(_ScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'subject_code': instance.subjectCode,
      'subject_name': instance.subjectName,
      'teacher': instance.teacher,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'days': instance.days,
      'room': instance.room,
      'academic_term_id': instance.academicTermId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
