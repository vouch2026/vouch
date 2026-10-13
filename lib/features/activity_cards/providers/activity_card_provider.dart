import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/activity_card_models.dart';
import '../repositories/activity_card_repository.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../academic_structure/providers/term_provider.dart';

final activityCardRepositoryProvider = Provider<ActivityCardRepository>((ref) {
  return ActivityCardRepository(SupabaseConfig.client);
});

final studentActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return [];

  // AY|SEM history: default active, selectable via the sidebar. Past = view-only.
  final viewingTerm = await ref.watch(viewingTermProvider.future);

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCards(userProfile.id as String,
      academicTermId: viewingTerm?.id);
});

final organizationActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final workspace = ref.watch(workspaceProvider);
  final selectedOrg = workspace.selectedOrganization;
  if (selectedOrg == null || selectedOrg.id == null) return [];

  final viewingTerm = await ref.watch(viewingTermProvider.future);

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getOrganizationActivityCards(selectedOrg.id,
      academicTermId: viewingTerm?.id);
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

  final viewingTerm = await ref.watch(viewingTermProvider.future);

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCardForOrganization(studentId, selectedOrg.id!, academicTermId: viewingTerm?.id);
});

final studentActivityCardsByIdProvider = FutureProvider.family<List<ActivityCard>, String>((ref, studentId) async {
  final viewingTerm = await ref.watch(viewingTermProvider.future);

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCards(studentId, academicTermId: viewingTerm?.id);
});
