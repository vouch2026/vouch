import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_model.dart';

final programsProvider = FutureProvider<List<ProgramModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    const ProgramModel(
      id: '1',
      name: 'BS Information Technology',
      code: 'BSIT',
      facultyId: '1',
      programHeadName: 'Prof. Alice Green',
    ),
    const ProgramModel(
      id: '2',
      name: 'BS Computer Science',
      code: 'BSCS',
      facultyId: '1',
      programHeadName: 'Prof. Bob Brown',
    ),
  ];
});

final programsByFacultyProvider = FutureProvider.family<List<ProgramModel>, String>((ref, facultyId) async {
  final programs = await ref.watch(programsProvider.future);
  return programs.where((p) => p.facultyId == facultyId).toList();
});
