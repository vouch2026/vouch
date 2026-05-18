import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campus_model.dart';
import '../repositories/campus_repository.dart';

final campusRepositoryProvider = Provider((ref) => CampusRepository());

final campusesProvider = FutureProvider<List<CampusModel>>((ref) async {
  final repository = ref.watch(campusRepositoryProvider);
  return repository.getCampuses();
});

final campusProvider = FutureProvider.family<CampusModel?, String>((ref, id) async {
  final campuses = await ref.watch(campusesProvider.future);
  try {
    return campuses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
