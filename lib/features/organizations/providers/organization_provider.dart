import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/organization_repository.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(SupabaseConfig.client);
});

final organizationsProvider = FutureProvider<List<OrganizationModel>>((ref) async {
  return ref.watch(organizationRepositoryProvider).getOrganizations();
});

final userOrganizationsProvider = FutureProvider<List<OrganizationModel>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return [];
  return ref.watch(organizationRepositoryProvider).getUserOrganizations(userProfile.id!);
});

final organizationProvider = FutureProvider.family<OrganizationModel?, String>((ref, id) async {
  return ref.watch(organizationRepositoryProvider).getOrganizationById(id);
});

final organizationMembersProvider = FutureProvider.family<List<UserModel>, String>((ref, orgId) async {
  return ref.watch(organizationRepositoryProvider).getOrganizationMembers(orgId);
});

final organizationOfficersProvider = FutureProvider.family<List<OrganizationMembershipModel>, String>((ref, orgId) async {
  return ref.watch(organizationRepositoryProvider).getOrganizationOfficers(orgId);
});

final availableRolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = SupabaseConfig.client;
  final response = await client
      .from('roles')
      .select()
      .order('hierarchy_level', ascending: false);
  return List<Map<String, dynamic>>.from(response as List);
});
