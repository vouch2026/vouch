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
      adviserName: json['adviser_name'] as String?,
      programHeadName: json['program_head_name'] as String?,
      deanName: json['dean_name'] as String?,
      campusId: json['campus_id'] as String?,
      facultyId: json['faculty_id'] as String?,
      programId: json['program_id'] as String?,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      requiresAdviserSignature:
          json['requires_adviser_signature'] as bool? ?? false,
      requiresProgramHeadSignature:
          json['requires_program_head_signature'] as bool? ?? false,
      requiresFacultyDeanSignature:
          json['requires_faculty_dean_signature'] as bool? ?? false,
      allowMemberCardPrinting:
          json['allow_member_card_printing'] as bool? ?? true,
      restrictClearanceRequest:
          json['restrict_clearance_request'] as bool? ?? false,
      isClearanceActive: json['is_clearance_active'] as bool? ?? false,
      clearancePeriodStart: json['clearance_period_start'] == null
          ? null
          : DateTime.parse(json['clearance_period_start'] as String),
      clearancePeriodEnd: json['clearance_period_end'] == null
          ? null
          : DateTime.parse(json['clearance_period_end'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$OrganizationModelToJson(
  _OrganizationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'logo_url': instance.logoUrl,
  'banner_url': instance.bannerUrl,
  'status': instance.status,
  'type': instance.type,
  'facultyProgram': instance.facultyProgram,
  'adviser_name': instance.adviserName,
  'program_head_name': instance.programHeadName,
  'dean_name': instance.deanName,
  'campus_id': instance.campusId,
  'faculty_id': instance.facultyId,
  'program_id': instance.programId,
  'memberCount': instance.memberCount,
  'requires_adviser_signature': instance.requiresAdviserSignature,
  'requires_program_head_signature': instance.requiresProgramHeadSignature,
  'requires_faculty_dean_signature': instance.requiresFacultyDeanSignature,
  'allow_member_card_printing': instance.allowMemberCardPrinting,
  'restrict_clearance_request': instance.restrictClearanceRequest,
  'is_clearance_active': instance.isClearanceActive,
  'clearance_period_start': instance.clearancePeriodStart?.toIso8601String(),
  'clearance_period_end': instance.clearancePeriodEnd?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};
