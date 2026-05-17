// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'election_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ElectionStatsModelImpl _$$ElectionStatsModelImplFromJson(
  Map<String, dynamic> json,
) => _$ElectionStatsModelImpl(
  activeElections: (json['activeElections'] as num?)?.toInt() ?? 0,
  upcomingElections: (json['upcomingElections'] as num?)?.toInt() ?? 0,
  completedElections: (json['completedElections'] as num?)?.toInt() ?? 0,
  registeredVoters: (json['registeredVoters'] as num?)?.toInt() ?? 0,
  totalVotesCast: (json['totalVotesCast'] as num?)?.toInt() ?? 0,
  voterTurnoutRate: (json['voterTurnoutRate'] as num?)?.toDouble() ?? 0.0,
  totalCandidates: (json['totalCandidates'] as num?)?.toInt() ?? 0,
  approvedCandidates: (json['approvedCandidates'] as num?)?.toInt() ?? 0,
  pendingCandidates: (json['pendingCandidates'] as num?)?.toInt() ?? 0,
  activeComselecOfficials:
      (json['activeComselecOfficials'] as num?)?.toInt() ?? 0,
  electionViolations: (json['electionViolations'] as num?)?.toInt() ?? 0,
  complianceRate: (json['complianceRate'] as num?)?.toDouble() ?? 0.0,
  turnoutTrend: (json['turnoutTrend'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$ElectionStatsModelImplToJson(
  _$ElectionStatsModelImpl instance,
) => <String, dynamic>{
  'activeElections': instance.activeElections,
  'upcomingElections': instance.upcomingElections,
  'completedElections': instance.completedElections,
  'registeredVoters': instance.registeredVoters,
  'totalVotesCast': instance.totalVotesCast,
  'voterTurnoutRate': instance.voterTurnoutRate,
  'totalCandidates': instance.totalCandidates,
  'approvedCandidates': instance.approvedCandidates,
  'pendingCandidates': instance.pendingCandidates,
  'activeComselecOfficials': instance.activeComselecOfficials,
  'electionViolations': instance.electionViolations,
  'complianceRate': instance.complianceRate,
  'turnoutTrend': instance.turnoutTrend,
};
