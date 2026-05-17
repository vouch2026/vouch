import 'package:freezed_annotation/freezed_annotation.dart';

part 'election_stats_model.freezed.dart';
part 'election_stats_model.g.dart';

@freezed
class ElectionStatsModel with _$ElectionStatsModel {
  const factory ElectionStatsModel({
    @Default(0) int activeElections,
    @Default(0) int upcomingElections,
    @Default(0) int completedElections,
    @Default(0) int registeredVoters,
    @Default(0) int totalVotesCast,
    @Default(0.0) double voterTurnoutRate,
    @Default(0) int totalCandidates,
    @Default(0) int approvedCandidates,
    @Default(0) int pendingCandidates,
    @Default(0) int activeComselecOfficials,
    @Default(0) int electionViolations,
    @Default(0.0) double complianceRate,
    @Default(0.0) double turnoutTrend,
  }) = _ElectionStatsModel;

  factory ElectionStatsModel.fromJson(Map<String, dynamic> json) => _$ElectionStatsModelFromJson(json);
}
