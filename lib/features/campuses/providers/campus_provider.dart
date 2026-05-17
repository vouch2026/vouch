import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campus_model.dart';

final campusesProvider = FutureProvider<List<CampusModel>>((ref) async {
  // Mock data
  await Future.delayed(const Duration(seconds: 1));
  return [
    const CampusModel(
      id: '1',
      name: 'DORSU Main Campus',
      location: 'Mati City, Davao Oriental',
      description: 'The main administrative and academic hub.',
    ),
    const CampusModel(
      id: '2',
      name: 'DORSU Banaybanay Campus',
      location: 'Banaybanay, Davao Oriental',
      description: 'Specializing in Agriculture and Technology.',
    ),
  ];
});

final campusProvider = FutureProvider.family<CampusModel?, String>((ref, id) async {
  final campuses = await ref.watch(campusesProvider.future);
  try {
    return campuses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});
