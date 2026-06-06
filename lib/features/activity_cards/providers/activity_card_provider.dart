import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/activity_card_models.dart';
import '../repositories/activity_card_repository.dart';

import '../../organizations/providers/managed_organization_provider.dart';

final activityCardRepositoryProvider = Provider<ActivityCardRepository>((ref) {
  return ActivityCardRepository(SupabaseConfig.client);
});

final studentActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return [];
  
  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCards(userProfile.id!);
});

final organizationActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final managedOrg = ref.watch(managedOrganizationProvider).value;
  if (managedOrg == null || managedOrg.id == null) return [];

  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getOrganizationActivityCards(managedOrg.id);
});

final activityCardDetailsProvider = Provider.family<AsyncValue<ActivityCard?>, String>((ref, id) {
  return ref.watch(studentActivityCardsProvider).whenData(
    (cards) => cards.where((c) => c.id == id).firstOrNull,
  );
});
