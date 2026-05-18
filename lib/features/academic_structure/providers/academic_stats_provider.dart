import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../campuses/providers/campus_provider.dart';
import '../../faculties/providers/faculty_provider.dart';
import '../../programs/providers/program_provider.dart';

final academicStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final campuses = await ref.watch(campusesProvider.future);
  final faculties = await ref.watch(facultiesProvider.future);
  final programs = await ref.watch(programsProvider.future);
  
  final client = SupabaseConfig.client;
  
  // Get total student count
  final studentResponse = await client.from('users').select('id');
  final totalStudents = (studentResponse as List).length;

  // Get total organizations count
  final orgResponse = await client.from('organizations').select('id');
  final totalOrgs = (orgResponse as List).length;

  return {
    'campusesCount': campuses.length,
    'activeCampuses': campuses.where((c) => c.status == 'active').length,
    'facultiesCount': faculties.length,
    'deansCount': faculties.where((f) => f.deanId != null).length,
    'programsCount': programs.length,
    'headsCount': programs.where((p) => p.programHeadId != null).length,
    'totalStudents': totalStudents,
    'totalOrgs': totalOrgs,
  };
});
