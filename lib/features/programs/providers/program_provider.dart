import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_model.dart';
import '../repositories/program_repository.dart';

final programRepositoryProvider = Provider((ref) => ProgramRepository());

class ProgramsNotifier extends AsyncNotifier<List<ProgramModel>> {
  @override
  FutureOr<List<ProgramModel>> build() async {
    final repository = ref.watch(programRepositoryProvider);
    return repository.getPrograms();
  }

  Future<void> addProgram(ProgramModel program) async {
    final repository = ref.read(programRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final newProgram = await repository.createProgram(program);
      final currentList = state.valueOrNull ?? [];
      return [...currentList, newProgram]..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> updateProgram(ProgramModel program) async {
    final repository = ref.read(programRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final updatedProgram = await repository.updateProgram(program);
      final currentList = state.valueOrNull ?? [];
      return currentList.map((p) => p.id == updatedProgram.id ? updatedProgram : p).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> deleteProgram(String id) async {
    final repository = ref.read(programRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repository.deleteProgram(id);
      final currentList = state.valueOrNull ?? [];
      return currentList.where((p) => p.id != id).toList();
    });
  }
}

final programsProvider = AsyncNotifierProvider<ProgramsNotifier, List<ProgramModel>>(
  () => ProgramsNotifier(),
);

final programsByFacultyProvider = FutureProvider.family<List<ProgramModel>, String>((ref, facultyId) async {
  final programs = await ref.watch(programsProvider.future);
  return programs.where((p) => p.facultyId == facultyId).toList();
});
