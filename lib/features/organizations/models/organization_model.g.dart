// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationModelImpl _$$OrganizationModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String?,
  logoUrl: json['logoUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  status: json['status'] as String? ?? 'active',
  type: json['type'] as String? ?? 'academic',
  facultyProgram: json['facultyProgram'] as String?,
  adviserName: json['adviserName'] as String?,
  campusId: json['campusId'] as String?,
  facultyId: json['facultyId'] as String?,
  programId: json['programId'] as String?,
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$OrganizationModelImplToJson(
  _$OrganizationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'logoUrl': instance.logoUrl,
  'bannerUrl': instance.bannerUrl,
  'status': instance.status,
  'type': instance.type,
  'facultyProgram': instance.facultyProgram,
  'adviserName': instance.adviserName,
  'campusId': instance.campusId,
  'facultyId': instance.facultyId,
  'programId': instance.programId,
  'memberCount': instance.memberCount,
  'createdAt': instance.createdAt?.toIso8601String(),
};
