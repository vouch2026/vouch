// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FacultyModel _$FacultyModelFromJson(Map<String, dynamic> json) =>
    _FacultyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      campusId: json['campus_id'] as String,
      deanId: json['dean_id'] as String?,
      deanName: json['deanName'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FacultyModelToJson(_FacultyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'campus_id': instance.campusId,
      'dean_id': instance.deanId,
      'deanName': instance.deanName,
      'logo_url': instance.logoUrl,
      'banner_url': instance.bannerUrl,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
