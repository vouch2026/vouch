// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationModel _$OrganizationModelFromJson(Map<String, dynamic> json) =>
    _OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      status: json['status'] as String? ?? 'active',
      type: json['type'] as String? ?? 'campus-based',
      facultyProgram: json['facultyProgram'] as String?,
      adviserName: json['adviserName'] as String?,
      campusId: json['campus_id'] as String?,
      facultyId: json['faculty_id'] as String?,
      programId: json['program_id'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      requiresAdviserSignature:
          json['requires_adviser_signature'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$OrganizationModelToJson(_OrganizationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'logo_url': instance.logoUrl,
      'banner_url': instance.bannerUrl,
      'status': instance.status,
      'type': instance.type,
      'facultyProgram': instance.facultyProgram,
      'adviserName': instance.adviserName,
      'campus_id': instance.campusId,
      'faculty_id': instance.facultyId,
      'program_id': instance.programId,
      'memberCount': instance.memberCount,
      'requires_adviser_signature': instance.requiresAdviserSignature,
      'created_at': instance.createdAt?.toIso8601String(),
    };
