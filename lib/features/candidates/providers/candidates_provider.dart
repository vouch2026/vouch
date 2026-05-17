import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/candidate_model.dart';

final candidatesProvider = FutureProvider<List<CandidateModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    const CandidateModel(
      id: 'c1',
      electionId: 'e1',
      userId: 'u1',
      fullName: 'Juan Dela Cruz',
      position: 'President',
      partyList: 'Progressive Party',
      status: 'approved',
      votes: 450,
      organizationName: 'SSC',
    ),
    const CandidateModel(
      id: 'c2',
      electionId: 'e1',
      userId: 'u2',
      fullName: 'Maria Clara',
      position: 'President',
      partyList: 'United Alliance',
      status: 'approved',
      votes: 420,
      organizationName: 'SSC',
    ),
    const CandidateModel(
      id: 'c3',
      electionId: 'e2',
      userId: 'u3',
      fullName: 'Jose Rizal',
      position: 'Governor',
      partyList: 'Innovators',
      status: 'pending',
      votes: 0,
      organizationName: 'FCET',
    ),
  ];
});
