// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FacultyModelImpl _$$FacultyModelImplFromJson(Map<String, dynamic> json) =>
    _$FacultyModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      campusId: json['campusId'] as String,
      deanId: json['deanId'] as String?,
      deanName: json['deanName'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FacultyModelImplToJson(_$FacultyModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'campusId': instance.campusId,
      'deanId': instance.deanId,
      'deanName': instance.deanName,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
