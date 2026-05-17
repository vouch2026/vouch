import 'package:freezed_annotation/freezed_annotation.dart';

part 'campus_stats.freezed.dart';
part 'campus_stats.g.dart';

@freezed
class CampusStats with _$CampusStats {
  const factory CampusStats({
    @Default(0) int totalCampuses,
    @Default(0) int activeCampuses,
    @Default(0) int totalFaculties,
    @Default(0) int activeDeans,
    @Default(0) int totalPrograms,
    @Default(0) int activeProgramHeads,
    @Default(0) int totalStudents,
    @Default(0) int totalOrganizations,
    @Default(0.0) double complianceRate,
    @Default(0.0) double trendPercentage,
  }) = _CampusStats;

  factory CampusStats.fromJson(Map<String, dynamic> json) => _$CampusStatsFromJson(json);
}
