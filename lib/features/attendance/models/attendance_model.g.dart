// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceModelImpl _$$AttendanceModelImplFromJson(
  Map<String, dynamic> json,
) => _$AttendanceModelImpl(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  eventId: json['event_id'] as String,
  actualTimeIn: json['actual_time_in'] == null
      ? null
      : DateTime.parse(json['actual_time_in'] as String),
  actualTimeOut: json['actual_time_out'] == null
      ? null
      : DateTime.parse(json['actual_time_out'] as String),
  status: json['status'] as String? ?? 'Pending',
  scannedByUserId: json['scanned_by_user_id'] as String?,
  overrideReason: json['override_reason'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$AttendanceModelImplToJson(
  _$AttendanceModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'event_id': instance.eventId,
  'actual_time_in': instance.actualTimeIn?.toIso8601String(),
  'actual_time_out': instance.actualTimeOut?.toIso8601String(),
  'status': instance.status,
  'scanned_by_user_id': instance.scannedByUserId,
  'override_reason': instance.overrideReason,
  'updated_at': instance.updatedAt?.toIso8601String(),
};
