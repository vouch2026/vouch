import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../academic_structure/providers/term_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../models/sanction_model.dart';
import '../repositories/sanction_repository.dart';
import '../../auth/providers/auth_provider.dart';

final sanctionRepositoryProvider = Provider<SanctionRepository>((ref) {
  return SanctionRepository(SupabaseConfig.client);
});

final workspaceSanctionsProvider = FutureProvider<List<SanctionModel>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final term = ref.watch(activeTermProvider).value;
  final org = workspace.selectedOrganization;

  if (org == null || term == null) return [];

  String? scopeId = org.campusId;
  if (org.type == 'faculty-based') {
    scopeId = org.facultyId;
  } else if (org.type == 'program-based') {
    scopeId = org.programId;
  }

  if (scopeId == null) return [];

  final repository = ref.watch(sanctionRepositoryProvider);
  return repository.getWorkspaceSanctions(scopeId, term.id);
});

final mySanctionsProvider = FutureProvider<List<SanctionModel>>((ref) async {
  final userProfile = await ref.watch(userProfileProvider.future);
  final term = await ref.watch(activeTermProvider.future);

  if (userProfile == null || userProfile.id == null || term == null) {
    debugPrint('mySanctionsProvider: Missing dependencies. profile: ${userProfile?.id}, term: ${term?.id}');
    return [];
  }

  debugPrint('mySanctionsProvider: Fetching all sanctions for student ${userProfile.id}, term ${term.id}');

  final repository = ref.watch(sanctionRepositoryProvider);
  // Fetching all sanctions for the student in the current term, regardless of workspace
  return repository.getMySanctions(userProfile.id!, termId: term.id);
});
