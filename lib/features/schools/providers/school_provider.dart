import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/school_model.dart';
import '../repositories/school_repository.dart';

final schoolRepositoryProvider = Provider((ref) => SchoolRepository());

final schoolsProvider = FutureProvider<List<SchoolModel>>((ref) async {
  return ref.watch(schoolRepositoryProvider).getSchools();
});
