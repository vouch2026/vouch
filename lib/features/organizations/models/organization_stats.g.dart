// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationStatsImpl _$$OrganizationStatsImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationStatsImpl(
  totalOrganizations: (json['totalOrganizations'] as num?)?.toInt() ?? 0,
  activeOrganizations: (json['activeOrganizations'] as num?)?.toInt() ?? 0,
  inactiveOrganizations: (json['inactiveOrganizations'] as num?)?.toInt() ?? 0,
  totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
  activeOfficers: (json['activeOfficers'] as num?)?.toInt() ?? 0,
  pendingApplications: (json['pendingApplications'] as num?)?.toInt() ?? 0,
  orgsWithElections: (json['orgsWithElections'] as num?)?.toInt() ?? 0,
  orgsWithSanctions: (json['orgsWithSanctions'] as num?)?.toInt() ?? 0,
  complianceRate: (json['complianceRate'] as num?)?.toDouble() ?? 0.0,
  trendPercentage: (json['trendPercentage'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$OrganizationStatsImplToJson(
  _$OrganizationStatsImpl instance,
) => <String, dynamic>{
  'totalOrganizations': instance.totalOrganizations,
  'activeOrganizations': instance.activeOrganizations,
  'inactiveOrganizations': instance.inactiveOrganizations,
  'totalMembers': instance.totalMembers,
  'activeOfficers': instance.activeOfficers,
  'pendingApplications': instance.pendingApplications,
  'orgsWithElections': instance.orgsWithElections,
  'orgsWithSanctions': instance.orgsWithSanctions,
  'complianceRate': instance.complianceRate,
  'trendPercentage': instance.trendPercentage,
};
