import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/storage_provider.dart';
import '../../sanctions/providers/sanction_provider.dart';
import '../models/excuse_request_model.dart';
import '../repositories/excuse_repository.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../auth/providers/auth_provider.dart';

final excuseRepositoryProvider = Provider<ExcuseRepository>((ref) {
  final client = SupabaseConfig.client;
  final storage = ref.read(storageServiceProvider);
  final sanctions = ref.read(sanctionRepositoryProvider);
  return ExcuseRepository(client, storage, sanctions);
});

final studentExcusesProvider = FutureProvider.family<List<ExcuseRequestModel>, String>((ref, studentId) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  final term = ref.watch(activeTermProvider).value;
  
  if (org == null || term == null) return [];
  
  String? scopeId = org.campusId;
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
  }
  
  if (scopeId == null) return [];
  
  final repo = ref.watch(excuseRepositoryProvider);
  return repo.getStudentExcuses(studentId, term.id, scopeId);
});

final workspaceExcuseRequestsProvider = FutureProvider<List<ExcuseRequestModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  final term = ref.watch(activeTermProvider).value;
  
  if (org == null || term == null) return [];
  
  String? scopeId = org.campusId;
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
  }
  
  if (scopeId == null) return [];
  
  final repo = ref.watch(excuseRepositoryProvider);
  return repo.getWorkspaceExcuses(scopeId, term.id);
});

final studentEventExcuseProvider = FutureProvider.family<ExcuseRequestModel?, String>((ref, eventId) async {
  final user = ref.watch(userProfileProvider).value;
  final term = ref.watch(activeTermProvider).value;
  final workspace = ref.watch(workspaceProvider);
  final org = workspace.selectedOrganization;
  
  if (user == null || term == null || org == null) return null;
  
  String? scopeId = org.campusId;
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
  }
  
  if (scopeId == null) return null;
  
  final repo = ref.watch(excuseRepositoryProvider);
  final excuses = await repo.getStudentExcuses(user.id!, term.id, scopeId);
  return excuses.where((e) => e.eventId == eventId).firstOrNull;
});

final workspaceExcuseRequestByIdProvider = FutureProvider.family<ExcuseRequestModel?, String>((ref, id) async {
  final repo = ref.watch(excuseRepositoryProvider);
  return repo.getExcuseRequestById(id);
});
