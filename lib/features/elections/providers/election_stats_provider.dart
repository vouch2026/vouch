import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/election_stats_model.dart';

final electionStatsProvider = FutureProvider<ElectionStatsModel>((ref) async {
  // Mocking data for university-wide elections
  await Future.delayed(const Duration(seconds: 1));
  
  return const ElectionStatsModel(
    activeElections: 3,
    upcomingElections: 5,
    completedElections: 12,
    registeredVoters: 12500,
    totalVotesCast: 9800,
    voterTurnoutRate: 78.4,
    totalCandidates: 48,
    approvedCandidates: 42,
    pendingCandidates: 6,
    activeComselecOfficials: 15,
    electionViolations: 2,
    complianceRate: 98.5,
    turnoutTrend: 5.4,
  );
});
