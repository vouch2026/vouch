// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampusStatsImpl _$$CampusStatsImplFromJson(Map<String, dynamic> json) =>
    _$CampusStatsImpl(
      totalCampuses: (json['totalCampuses'] as num?)?.toInt() ?? 0,
      activeCampuses: (json['activeCampuses'] as num?)?.toInt() ?? 0,
      totalFaculties: (json['totalFaculties'] as num?)?.toInt() ?? 0,
      activeDeans: (json['activeDeans'] as num?)?.toInt() ?? 0,
      totalPrograms: (json['totalPrograms'] as num?)?.toInt() ?? 0,
      activeProgramHeads: (json['activeProgramHeads'] as num?)?.toInt() ?? 0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      totalOrganizations: (json['totalOrganizations'] as num?)?.toInt() ?? 0,
      complianceRate: (json['complianceRate'] as num?)?.toDouble() ?? 0.0,
      trendPercentage: (json['trendPercentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$CampusStatsImplToJson(_$CampusStatsImpl instance) =>
    <String, dynamic>{
      'totalCampuses': instance.totalCampuses,
      'activeCampuses': instance.activeCampuses,
      'totalFaculties': instance.totalFaculties,
      'activeDeans': instance.activeDeans,
      'totalPrograms': instance.totalPrograms,
      'activeProgramHeads': instance.activeProgramHeads,
      'totalStudents': instance.totalStudents,
      'totalOrganizations': instance.totalOrganizations,
      'complianceRate': instance.complianceRate,
      'trendPercentage': instance.trendPercentage,
    };
