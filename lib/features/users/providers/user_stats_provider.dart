import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats_model.dart';

final userStatsProvider = FutureProvider<UserStatsModel>((ref) async {
  // Mocking data for institutional users
  await Future.delayed(const Duration(seconds: 1));
  
  return const UserStatsModel(
    totalStudents: 12500,
    activeStudents: 11800,
    pendingStudents: 450,
    suspendedStudents: 250,
    totalInstructors: 450,
    activeInstructors: 420,
    deansCount: 12,
    programHeadsCount: 32,
    totalOfficers: 180,
    orgMembershipsCount: 3200,
    activeGovernanceAccounts: 150,
    studentTrend: 5.2,
    instructorTrend: 2.1,
    governanceTrend: 8.4,
  );
});
