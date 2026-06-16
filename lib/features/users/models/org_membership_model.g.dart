// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'org_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrgMembershipModel _$OrgMembershipModelFromJson(Map<String, dynamic> json) =>
    _OrgMembershipModel(
      organizationId: json['organizationId'] as String,
      organizationName: json['organizationName'] as String,
      role: json['role'] as String,
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
      isCurrent: json['isCurrent'] as bool? ?? true,
      positionTitle: json['positionTitle'] as String?,
    );

Map<String, dynamic> _$OrgMembershipModelToJson(_OrgMembershipModel instance) =>
    <String, dynamic>{
      'organizationId': instance.organizationId,
      'organizationName': instance.organizationName,
      'role': instance.role,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'isCurrent': instance.isCurrent,
      'positionTitle': instance.positionTitle,
    };
