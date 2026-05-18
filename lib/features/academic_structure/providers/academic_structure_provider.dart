import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';
import '../models/academic_structure_item.dart';
import '../../../core/config/supabase_config.dart';

final studentCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final client = SupabaseConfig.client;
  final response = await client.from('users').select('program_id');
  final counts = <String, int>{};
  for (final row in response as List) {
    final programId = row['program_id'] as String?;
    if (programId != null) {
      counts[programId] = (counts[programId] ?? 0) + 1;
    }
  }
  return counts;
});

final orgCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final client = SupabaseConfig.client;
  final response = await client.from('organizations').select('program_id');
  final counts = <String, int>{};
  for (final row in response as List) {
    final programId = row['program_id'] as String?;
    if (programId != null) {
      counts[programId] = (counts[programId] ?? 0) + 1;
    }
  }
  return counts;
});

final academicStructureProvider = FutureProvider<List<AcademicStructureItem>>((ref) async {
  final campuses = await ref.watch(campusesProvider.future);
  final faculties = await ref.watch(facultiesProvider.future);
  final programs = await ref.watch(programsProvider.future);
  
  final studentCounts = await ref.watch(studentCountsProvider.future);
  final orgCounts = await ref.watch(orgCountsProvider.future);

  final items = <AcademicStructureItem>[];

  for (final program in programs) {
    try {
      final faculty = faculties.firstWhere((f) => f.id == program.facultyId);
      final campus = campuses.firstWhere((c) => c.id == faculty.campusId);

      items.add(AcademicStructureItem(
        campusName: campus.name,
        facultyName: faculty.name,
        programName: program.name,
        programId: program.id,
        facultyId: faculty.id,
        campusId: campus.id,
        programHeadName: program.programHeadName,
        studentCount: studentCounts[program.id] ?? 0,
        orgCount: orgCounts[program.id] ?? 0,
        status: campus.status, 
      ));
    } catch (e) {
      // Skip programs with missing faculty/campus data
      continue;
    }
  }

  return items;
});
