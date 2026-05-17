// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      schoolId: json['schoolId'] as String?,
      faculty: json['faculty'] as String?,
      program: json['program'] as String?,
      yearLevel: (json['yearLevel'] as num?)?.toInt(),
      avatarUrl: json['avatarUrl'] as String?,
      idFrontUrl: json['idFrontUrl'] as String?,
      idBackUrl: json['idBackUrl'] as String?,
      organizationIds:
          (json['organizationIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'schoolId': instance.schoolId,
      'faculty': instance.faculty,
      'program': instance.program,
      'yearLevel': instance.yearLevel,
      'avatarUrl': instance.avatarUrl,
      'idFrontUrl': instance.idFrontUrl,
      'idBackUrl': instance.idBackUrl,
      'organizationIds': instance.organizationIds,
      'role': instance.role,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
