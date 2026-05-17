import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/organization_stats.dart';

final organizationStatsProvider = FutureProvider<OrganizationStats>((ref) async {
  // Mocking data for now
  await Future.delayed(const Duration(seconds: 1));
  
  return const OrganizationStats(
    totalOrganizations: 48,
    activeOrganizations: 42,
    inactiveOrganizations: 6,
    totalMembers: 1250,
    activeOfficers: 180,
    pendingApplications: 12,
    orgsWithElections: 35,
    orgsWithSanctions: 2,
    complianceRate: 94.5,
    trendPercentage: 5.2,
  );
});
