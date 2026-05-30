// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationMembershipModelImpl _$$OrganizationMembershipModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationMembershipModelImpl(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  userId: json['user_id'] as String,
  roleId: json['role_id'] as String?,
  academicTermId: json['academic_term_id'] as String?,
  status: json['status'] as String? ?? 'active',
  assignedAt: json['assigned_at'] == null
      ? null
      : DateTime.parse(json['assigned_at'] as String),
  expiredAt: json['expired_at'] == null
      ? null
      : DateTime.parse(json['expired_at'] as String),
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  user: json['user'] == null
      ? null
      : UserModel.fromJson(json['user'] as Map<String, dynamic>),
  term: json['term'] == null
      ? null
      : AcademicTermModel.fromJson(json['term'] as Map<String, dynamic>),
  roleName: json['role_name'] as String?,
  hierarchyLevel: (json['hierarchy_level'] as num?)?.toInt(),
  permissions:
      (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$OrganizationMembershipModelImplToJson(
  _$OrganizationMembershipModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'user_id': instance.userId,
  'role_id': instance.roleId,
  'academic_term_id': instance.academicTermId,
  'status': instance.status,
  'assigned_at': instance.assignedAt?.toIso8601String(),
  'expired_at': instance.expiredAt?.toIso8601String(),
  'joined_at': instance.joinedAt?.toIso8601String(),
  'user': instance.user,
  'term': instance.term,
  'role_name': instance.roleName,
  'hierarchy_level': instance.hierarchyLevel,
  'permissions': instance.permissions,
};
