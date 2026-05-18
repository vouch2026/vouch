import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty_model.dart';
import '../repositories/faculty_repository.dart';

final facultyRepositoryProvider = Provider((ref) => FacultyRepository());

final facultiesProvider = FutureProvider<List<FacultyModel>>((ref) async {
  final repository = ref.watch(facultyRepositoryProvider);
  return repository.getFaculties();
});

final facultiesByCampusProvider = FutureProvider.family<List<FacultyModel>, String>((ref, campusId) async {
  final repository = ref.watch(facultyRepositoryProvider);
  return repository.getFaculties(campusId: campusId);
});
