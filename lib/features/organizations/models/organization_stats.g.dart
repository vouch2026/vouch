// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationStats _$OrganizationStatsFromJson(Map<String, dynamic> json) =>
    _OrganizationStats(
      totalOrganizations: (json['totalOrganizations'] as num?)?.toInt() ?? 0,
      activeOrganizations: (json['activeOrganizations'] as num?)?.toInt() ?? 0,
      inactiveOrganizations:
          (json['inactiveOrganizations'] as num?)?.toInt() ?? 0,
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      activeOfficers: (json['activeOfficers'] as num?)?.toInt() ?? 0,
      pendingApplications: (json['pendingApplications'] as num?)?.toInt() ?? 0,
      orgsWithElections: (json['orgsWithElections'] as num?)?.toInt() ?? 0,
      orgsWithSanctions: (json['orgsWithSanctions'] as num?)?.toInt() ?? 0,
      complianceRate: (json['complianceRate'] as num?)?.toDouble() ?? 0.0,
      trendPercentage: (json['trendPercentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$OrganizationStatsToJson(_OrganizationStats instance) =>
    <String, dynamic>{
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
