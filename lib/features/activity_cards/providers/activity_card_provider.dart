import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/activity_card_models.dart';
import '../repositories/activity_card_repository.dart';
import '../../organizations/providers/workspace_provider.dart';

import '../../academic_structure/providers/academic_context_provider.dart';

final activityCardRepositoryProvider = Provider<ActivityCardRepository>((ref) {
  return ActivityCardRepository(SupabaseConfig.client);
});

final studentActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  final selectedTerm = ref.watch(selectedAcademicTermProvider);
  if (userProfile == null || userProfile.id == null) return [];
  
  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCards(userProfile.id as String, targetTermId: selectedTerm?.id);
});

final organizationActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final selectedOrg = workspace.selectedOrganization;
  if (selectedOrg == null || selectedOrg.id == null) return [];

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getOrganizationActivityCards(selectedOrg.id);
});

final activityCardDetailsProvider = Provider.family<AsyncValue<ActivityCard?>, String>((ref, organizationId) {
  return ref.watch(studentActivityCardsProvider).whenData(
    (cards) => cards.where((c) => c.organizationId == organizationId).firstOrNull,
  );
});

final reviewActivityCardProvider = FutureProvider.family<ActivityCard?, String>((ref, studentId) async {
  final workspace = ref.watch(workspaceProvider);
  final selectedOrg = workspace.selectedOrganization;
  if (selectedOrg == null || selectedOrg.id == null) return null;

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCardForOrganization(studentId, selectedOrg.id!);
});

final studentActivityCardsByIdProvider = FutureProvider.family<List<ActivityCard>, String>((ref, studentId) async {
  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCards(studentId);
});
