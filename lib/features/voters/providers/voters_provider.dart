import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voter_model.dart';

final votersProvider = FutureProvider<List<VoterModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    const VoterModel(
      id: 'v1',
      userId: 'u1',
      electionId: 'e1',
      studentNumber: '2022-00123',
      fullName: 'Juan Dela Cruz',
      status: 'voted',
      programName: 'BSIT',
    ),
    const VoterModel(
      id: 'v2',
      userId: 'u2',
      electionId: 'e1',
      studentNumber: '2022-00456',
      fullName: 'Maria Clara',
      status: 'eligible',
      programName: 'BEED',
    ),
  ];
});
