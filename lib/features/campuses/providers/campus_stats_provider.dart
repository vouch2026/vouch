import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campus_stats.dart';

final campusStatsProvider = FutureProvider<CampusStats>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return const CampusStats(
    totalCampuses: 4,
    activeCampuses: 4,
    totalFaculties: 12,
    activeDeans: 10,
    totalPrograms: 32,
    activeProgramHeads: 28,
    totalStudents: 12500,
    totalOrganizations: 48,
    complianceRate: 92.4,
    trendPercentage: 4.5,
  );
});
