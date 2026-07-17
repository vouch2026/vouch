import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/organization_repository.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../models/organization_settings_history_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import 'workspace_provider.dart';
import '../../../core/utils/role_mapper.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  return OrganizationRepository(SupabaseConfig.client);
});

final organizationsProvider = FutureProvider<List<OrganizationModel>>((ref) async {
  final allOrgs = await ref.watch(organizationRepositoryProvider).getOrganizations();
  
  final activeRole = ref.watch(workspaceProvider).activeRole;
  if (activeRole == null) return allOrgs;

  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null) return allOrgs;

  final roleKey = RoleMapper.mapDbRoleToAppFormat(activeRole.roleName);
  
  if (roleKey == 'program_head') {
    final programId = userProfile.programId;
    if (programId == null) return [];
    return allOrgs.where((org) => org.type == 'program-based' && org.programId == programId).toList();
  } else if (roleKey == 'dean') {
    final facultyId = userProfile.facultyId;
    if (facultyId == null) return [];
    return allOrgs.where((org) => org.type == 'faculty-based' && org.facultyId == facultyId).toList();
  }

  return allOrgs;
});

final userOrganizationsProvider = FutureProvider<List<OrganizationModel>>((ref) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return [];
  return ref.watch(organizationRepositoryProvider).getUserOrganizations(userProfile.id!);
});

final userMembershipInOrgProvider = FutureProvider.family<OrganizationMembershipModel?, String>((ref, orgId) async {
  final userProfile = ref.watch(userProfileProvider).value;
  if (userProfile == null || userProfile.id == null) return null;
  return ref.watch(organizationRepositoryProvider).getUserMembershipInOrg(userProfile.id!, orgId);
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

final organizationSettingsHistoryProvider = FutureProvider.family<List<OrganizationSettingsHistoryModel>, String>((ref, orgId) async {
  return ref.watch(organizationRepositoryProvider).getOrganizationSettingsHistory(orgId);
});

final availableRolesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = SupabaseConfig.client;
  final response = await client
      .from('roles')
      .select()
      .order('hierarchy_level', ascending: false);
  return List<Map<String, dynamic>>.from(response as List);
});
