import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/user_model.dart';
import 'users_provider.dart';

final userProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
  // Check students first
  final students = await ref.watch(studentsProvider.future);
  final student = students.firstWhere((s) => (s['user'] as UserModel).id == id, orElse: () => {});
  if (student.isNotEmpty) return student;

  // Then instructors
  final instructors = await ref.watch(instructorsProvider.future);
  final instructor = instructors.firstWhere((i) => (i['user'] as UserModel).id == id, orElse: () => {});
  if (instructor.isNotEmpty) return instructor;

  return null;
});
