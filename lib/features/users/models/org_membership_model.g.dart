// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrgMembershipModelImpl _$$OrgMembershipModelImplFromJson(
  Map<String, dynamic> json,
) => _$OrgMembershipModelImpl(
  organizationId: json['organizationId'] as String,
  organizationName: json['organizationName'] as String,
  role: json['role'] as String,
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
  isCurrent: json['isCurrent'] as bool? ?? true,
  positionTitle: json['positionTitle'] as String?,
);

Map<String, dynamic> _$$OrgMembershipModelImplToJson(
  _$OrgMembershipModelImpl instance,
) => <String, dynamic>{
  'organizationId': instance.organizationId,
  'organizationName': instance.organizationName,
  'role': instance.role,
  'joinedAt': instance.joinedAt?.toIso8601String(),
  'isCurrent': instance.isCurrent,
  'positionTitle': instance.positionTitle,
};
