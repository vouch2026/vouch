import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty_model.dart';

final facultiesProvider = FutureProvider<List<FacultyModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    const FacultyModel(
      id: '1',
      name: 'Faculty of Computing, Engineering and Technology',
      code: 'FCET',
      campusId: '1',
      deanName: 'Dr. John Doe',
    ),
    const FacultyModel(
      id: '2',
      name: 'Faculty of Teacher Education',
      code: 'FTE',
      campusId: '1',
      deanName: 'Dr. Jane Smith',
    ),
  ];
});

final facultiesByCampusProvider = FutureProvider.family<List<FacultyModel>, String>((ref, campusId) async {
  final faculties = await ref.watch(facultiesProvider.future);
  return faculties.where((f) => f.campusId == campusId).toList();
});
