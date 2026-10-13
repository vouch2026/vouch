import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campus_model.dart';
import '../repositories/campus_repository.dart';

final campusRepositoryProvider = Provider((ref) => CampusRepository());

class CampusesNotifier extends AsyncNotifier<List<CampusModel>> {
  @override
  FutureOr<List<CampusModel>> build() async {
    final repository = ref.watch(campusRepositoryProvider);
    return repository.getCampuses();
  }

  Future<void> addCampus(CampusModel campus, {String? schoolId}) async {
    final repository = ref.read(campusRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final newCampus =
          await repository.createCampus(campus, schoolId: schoolId);
      final currentList = state.valueOrNull ?? [];
      return [...currentList, newCampus]..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> updateCampus(CampusModel campus) async {
    final repository = ref.read(campusRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final updatedCampus = await repository.updateCampus(campus);
      final currentList = state.valueOrNull ?? [];
      return currentList.map((c) => c.id == updatedCampus.id ? updatedCampus : c).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> deleteCampus(String id) async {
    final repository = ref.read(campusRepositoryProvider);
    state = await AsyncValue.guard(() async {
      await repository.deleteCampus(id);
      final currentList = state.valueOrNull ?? [];
      return currentList.where((c) => c.id != id).toList();
    });
  }
}

final campusesProvider = AsyncNotifierProvider<CampusesNotifier, List<CampusModel>>(
  () => CampusesNotifier(),
);

final campusProvider = FutureProvider.family<CampusModel?, String>((ref, id) async {
  final campuses = await ref.watch(campusesProvider.future);
  try {
    return campuses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

/// Campuses belonging to a school. Campuses with a null `schoolId` (legacy
/// rows predating the schools migration) are treated as belonging to the
/// requested school when it is the only school — matching the DB backfill
/// rule that attached orphan campuses to DORSU.
final campusesBySchoolProvider =
    FutureProvider.family<List<CampusModel>, String>((ref, schoolId) async {
  final campuses = await ref.watch(campusesProvider.future);
  final scoped = campuses.where((c) => c.schoolId == schoolId).toList();
  if (scoped.isNotEmpty) return scoped;
  final unscoped = campuses.where((c) => c.schoolId == null).toList();
  if (unscoped.isNotEmpty && campuses.every((c) => c.schoolId == null)) {
    return unscoped;
  }
  return scoped;
});
