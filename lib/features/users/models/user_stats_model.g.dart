// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserStatsModelImpl _$$UserStatsModelImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsModelImpl(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      activeStudents: (json['activeStudents'] as num?)?.toInt() ?? 0,
      pendingStudents: (json['pendingStudents'] as num?)?.toInt() ?? 0,
      suspendedStudents: (json['suspendedStudents'] as num?)?.toInt() ?? 0,
      totalInstructors: (json['totalInstructors'] as num?)?.toInt() ?? 0,
      activeInstructors: (json['activeInstructors'] as num?)?.toInt() ?? 0,
      deansCount: (json['deansCount'] as num?)?.toInt() ?? 0,
      programHeadsCount: (json['programHeadsCount'] as num?)?.toInt() ?? 0,
      totalOfficers: (json['totalOfficers'] as num?)?.toInt() ?? 0,
      orgMembershipsCount: (json['orgMembershipsCount'] as num?)?.toInt() ?? 0,
      activeGovernanceAccounts:
          (json['activeGovernanceAccounts'] as num?)?.toInt() ?? 0,
      studentTrend: (json['studentTrend'] as num?)?.toDouble() ?? 0.0,
      instructorTrend: (json['instructorTrend'] as num?)?.toDouble() ?? 0.0,
      governanceTrend: (json['governanceTrend'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$UserStatsModelImplToJson(
  _$UserStatsModelImpl instance,
) => <String, dynamic>{
  'totalUsers': instance.totalUsers,
  'totalStudents': instance.totalStudents,
  'activeStudents': instance.activeStudents,
  'pendingStudents': instance.pendingStudents,
  'suspendedStudents': instance.suspendedStudents,
  'totalInstructors': instance.totalInstructors,
  'activeInstructors': instance.activeInstructors,
  'deansCount': instance.deansCount,
  'programHeadsCount': instance.programHeadsCount,
  'totalOfficers': instance.totalOfficers,
  'orgMembershipsCount': instance.orgMembershipsCount,
  'activeGovernanceAccounts': instance.activeGovernanceAccounts,
  'studentTrend': instance.studentTrend,
  'instructorTrend': instance.instructorTrend,
  'governanceTrend': instance.governanceTrend,
};
