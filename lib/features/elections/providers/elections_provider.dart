import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/election_model.dart';

final electionsProvider = FutureProvider<List<ElectionModel>>((ref) async {
  // Mocking institutional elections
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    ElectionModel(
      id: 'e1',
      name: 'SSC General Election 2026',
      organizationId: 'ssc',
      type: 'SSC',
      startTime: DateTime(2026, 5, 20, 8, 0),
      endTime: DateTime(2026, 5, 20, 17, 0),
      status: 'upcoming',
      createdBy: 'Super Admin',
      candidateCount: 12,
      votesCast: 0,
    ),
    ElectionModel(
      id: 'e2',
      name: 'FCET Student Council Election',
      organizationId: 'fcet',
      type: 'Department',
      startTime: DateTime(2026, 5, 17, 8, 0),
      endTime: DateTime(2026, 5, 17, 17, 0),
      status: 'ongoing',
      createdBy: 'Super Admin',
      candidateCount: 8,
      votesCast: 1450,
    ),
    ElectionModel(
      id: 'e3',
      name: 'Google Developer Student Club Officers',
      organizationId: 'gdsc',
      type: 'Organization',
      startTime: DateTime(2026, 5, 10, 8, 0),
      endTime: DateTime(2026, 5, 10, 17, 0),
      status: 'completed',
      createdBy: 'Super Admin',
      candidateCount: 6,
      votesCast: 240,
    ),
  ];
});
