import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats_model.freezed.dart';
part 'user_stats_model.g.dart';

@freezed
class UserStatsModel with _$UserStatsModel {
  const factory UserStatsModel({
    @Default(0) int totalStudents,
    @Default(0) int activeStudents,
    @Default(0) int pendingStudents,
    @Default(0) int suspendedStudents,
    @Default(0) int totalInstructors,
    @Default(0) int activeInstructors,
    @Default(0) int deansCount,
    @Default(0) int programHeadsCount,
    @Default(0) int totalOfficers,
    @Default(0) int orgMembershipsCount,
    @Default(0) int activeGovernanceAccounts,
    @Default(0.0) double studentTrend,
    @Default(0.0) double instructorTrend,
    @Default(0.0) double governanceTrend,
  }) = _UserStatsModel;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) => _$UserStatsModelFromJson(json);
}
