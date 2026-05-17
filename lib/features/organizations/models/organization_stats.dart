import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization_stats.freezed.dart';
part 'organization_stats.g.dart';

@freezed
class OrganizationStats with _$OrganizationStats {
  const factory OrganizationStats({
    @Default(0) int totalOrganizations,
    @Default(0) int activeOrganizations,
    @Default(0) int inactiveOrganizations,
    @Default(0) int totalMembers,
    @Default(0) int activeOfficers,
    @Default(0) int pendingApplications,
    @Default(0) int orgsWithElections,
    @Default(0) int orgsWithSanctions,
    @Default(0.0) double complianceRate,
    @Default(0.0) double trendPercentage,
  }) = _OrganizationStats;

  factory OrganizationStats.fromJson(Map<String, dynamic> json) => _$OrganizationStatsFromJson(json);
}
