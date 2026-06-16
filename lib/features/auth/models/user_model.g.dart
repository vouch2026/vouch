// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String?,
  authId: json['auth_id'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  schoolId: json['student_id_number'] as String,
  facultyId: json['faculty_id'] as String?,
  programId: json['program_id'] as String?,
  campusId: json['campus_id'] as String?,
  yearLevel: (json['year'] as num?)?.toInt(),
  avatarUrl: json['profile_photo_url'] as String?,
  idFrontUrl: json['id_front_url'] as String?,
  idBackUrl: json['id_back_url'] as String?,
  organizationIds:
      (json['organization_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  role: json['role'] as String? ?? 'student',
  status: json['account_status'] as String? ?? 'active',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  facultyName: json['facultyName'] as String?,
  programName: json['programName'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'auth_id': instance.authId,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'student_id_number': instance.schoolId,
      'faculty_id': instance.facultyId,
      'program_id': instance.programId,
      'campus_id': instance.campusId,
      'year': instance.yearLevel,
      'profile_photo_url': instance.avatarUrl,
      'id_front_url': instance.idFrontUrl,
      'id_back_url': instance.idBackUrl,
      'organization_ids': instance.organizationIds,
      'role': instance.role,
      'account_status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'joined_at': instance.joinedAt?.toIso8601String(),
      'facultyName': instance.facultyName,
      'programName': instance.programName,
    };
