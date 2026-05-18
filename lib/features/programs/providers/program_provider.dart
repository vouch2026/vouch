import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_model.dart';
import '../repositories/program_repository.dart';

final programRepositoryProvider = Provider((ref) => ProgramRepository());

final programsProvider = FutureProvider<List<ProgramModel>>((ref) async {
  final repository = ref.watch(programRepositoryProvider);
  return repository.getPrograms();
});

final programsByFacultyProvider = FutureProvider.family<List<ProgramModel>, String>((ref, facultyId) async {
  final repository = ref.watch(programRepositoryProvider);
  return repository.getPrograms(facultyId: facultyId);
});
