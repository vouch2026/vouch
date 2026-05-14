import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/organization_repository.dart';
import '../models/organization_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(SupabaseConfig.client);
});

final organizationsProvider = FutureProvider<List<OrganizationModel>>((ref) async {
  return ref.watch(organizationRepositoryProvider).getOrganizations();
});

final userOrganizationsProvider = FutureProvider<List<OrganizationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(organizationRepositoryProvider).getUserOrganizations(user.id);
});

final organizationProvider = FutureProvider.family<OrganizationModel?, String>((ref, id) async {
  return ref.watch(organizationRepositoryProvider).getOrganizationById(id);
});
