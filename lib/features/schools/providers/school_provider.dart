import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/school_model.dart';
import '../repositories/school_repository.dart';

final schoolRepositoryProvider = Provider((ref) => SchoolRepository());

class SchoolsNotifier extends AsyncNotifier<List<SchoolModel>> {
  @override
  FutureOr<List<SchoolModel>> build() async {
    final repository = ref.watch(schoolRepositoryProvider);
    return repository.getSchools();
  }

  Future<void> addSchool(SchoolModel school) async {
    final repository = ref.read(schoolRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final newSchool = await repository.createSchool(school);
      final currentList = state.valueOrNull ?? [];
      return [...currentList, newSchool]..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> updateSchool(SchoolModel school) async {
    final repository = ref.read(schoolRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final updatedSchool = await repository.updateSchool(school);
      final currentList = state.valueOrNull ?? [];
      return currentList.map((s) => s.id == updatedSchool.id ? updatedSchool : s).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> deleteSchool(String id) async {
    final repository = ref.read(schoolRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repository.deleteSchool(id);
      final currentList = state.valueOrNull ?? [];
      return currentList.where((s) => s.id != id).toList();
    });
  }
}

final schoolsProvider = AsyncNotifierProvider<SchoolsNotifier, List<SchoolModel>>(
  () => SchoolsNotifier(),
);

final schoolProvider = FutureProvider.family<SchoolModel?, String>((ref, id) async {
  final schools = await ref.watch(schoolsProvider.future);
  try {
    return schools.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});
