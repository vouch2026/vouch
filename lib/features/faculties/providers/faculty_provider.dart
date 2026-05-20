import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty_model.dart';
import '../repositories/faculty_repository.dart';

final facultyRepositoryProvider = Provider((ref) => FacultyRepository());

class FacultiesNotifier extends AsyncNotifier<List<FacultyModel>> {
  @override
  FutureOr<List<FacultyModel>> build() async {
    final repository = ref.watch(facultyRepositoryProvider);
    return repository.getFaculties();
  }

  Future<void> addFaculty(FacultyModel faculty) async {
    final repository = ref.read(facultyRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final newFaculty = await repository.createFaculty(faculty);
      final currentList = state.valueOrNull ?? [];
      return [...currentList, newFaculty]..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> updateFaculty(FacultyModel faculty) async {
    final repository = ref.read(facultyRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final updatedFaculty = await repository.updateFaculty(faculty);
      final currentList = state.valueOrNull ?? [];
      return currentList.map((f) => f.id == updatedFaculty.id ? updatedFaculty : f).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> deleteFaculty(String id) async {
    final repository = ref.read(facultyRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repository.deleteFaculty(id);
      final currentList = state.valueOrNull ?? [];
      return currentList.where((f) => f.id != id).toList();
    });
  }
}

final facultiesProvider = AsyncNotifierProvider<FacultiesNotifier, List<FacultyModel>>(
  () => FacultiesNotifier(),
);

final facultiesByCampusProvider = FutureProvider.family<List<FacultyModel>, String>((ref, campusId) async {
  final faculties = await ref.watch(facultiesProvider.future);
  return faculties.where((f) => f.campusId == campusId).toList();
});
