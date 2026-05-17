// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgramModelImpl _$$ProgramModelImplFromJson(Map<String, dynamic> json) =>
    _$ProgramModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      facultyId: json['facultyId'] as String,
      programHeadId: json['programHeadId'] as String?,
      programHeadName: json['programHeadName'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ProgramModelImplToJson(_$ProgramModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'facultyId': instance.facultyId,
      'programHeadId': instance.programHeadId,
      'programHeadName': instance.programHeadName,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
