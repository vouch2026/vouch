import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/activity_card_models.dart';
import '../repositories/activity_card_repository.dart';

final activityCardRepositoryProvider = Provider<ActivityCardRepository>((ref) {
  return ActivityCardRepository(SupabaseConfig.client);
});

final studentActivityCardsProvider = FutureProvider<List<ActivityCard>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return [];
  
  final repository = ref.watch(activityCardRepositoryProvider);
  return repository.getStudentActivityCards(userProfile.id!);
});

final activityCardDetailsProvider = FutureProvider.family<ActivityCard?, String>((ref, id) async {
  final cards = await ref.watch(studentActivityCardsProvider.future);
  return cards.where((c) => c.id == id).firstOrNull;
});
