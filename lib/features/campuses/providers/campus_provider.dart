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

  Future<void> addCampus(CampusModel campus) async {
    final repository = ref.read(campusRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final newCampus = await repository.createCampus(campus);
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
