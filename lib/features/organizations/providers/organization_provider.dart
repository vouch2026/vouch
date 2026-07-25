import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/organization_repository.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../models/organization_settings_history_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import 'workspace_provider.dart';
import '../../../core/utils/role_mapper.dart';
import '../../events/models/event_model.dart';
import '../../events/providers/event_provider.dart';
import '../../finance/models/fee_model.dart';
import '../../finance/providers/finance_provider.dart';
import '../../announcements/models/announcement_model.dart';
import '../../announcements/providers/announcement_provider.dart';

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
  
  final box = Hive.box('workspaces');
  final cacheKey = 'user_orgs_${userProfile.id}';
  try {
    final orgs = await ref.watch(organizationRepositoryProvider).getUserOrganizations(userProfile.id!);
    final orgsJson = orgs.map((org) => org.toJson()).toList();
    await box.put(cacheKey, orgsJson);
    return orgs;
  } catch (e) {
    final cached = box.get(cacheKey);
    if (cached != null) {
      final cachedList = List<dynamic>.from(cached as List);
      return cachedList.map((json) {
        final jsonMap = Map<String, dynamic>.from(json as Map);
        return OrganizationModel.fromJson(jsonMap);
      }).toList();
    }
    rethrow;
  }
});

final userMembershipsProvider = FutureProvider.family<List<UserOrganizationMembershipInfo>, String>((ref, userId) async {
  return ref.watch(organizationRepositoryProvider).getUserMemberships(userId);
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

final orgEventsProvider = FutureProvider.family<List<EventModel>, OrganizationModel>((ref, org) async {
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional ? 'Institutional' : (isFaculty ? 'Faculty' : 'Program');
  final scopeId = isInstitutional ? org.campusId : (isFaculty ? org.facultyId : org.programId);
  if (scopeId == null) return [];
  
  return ref.watch(eventRepositoryProvider).getEventsByScope(scopeType, scopeId);
});

final orgFeesProvider = FutureProvider.family<List<FeeModel>, OrganizationModel>((ref, org) async {
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional ? 'Institutional' : (isFaculty ? 'Faculty' : 'Program');
  final scopeId = isInstitutional ? org.campusId : (isFaculty ? org.facultyId : org.programId);
  if (scopeId == null) return [];
  
  return ref.watch(financeRepositoryProvider).getFeesByScope(scopeType, scopeId);
});

final orgAnnouncementsProvider = FutureProvider.family<List<AnnouncementModel>, OrganizationModel>((ref, org) async {
  final isInstitutional = org.type == 'campus-based' || org.type == 'institutional';
  final isFaculty = org.type == 'faculty-based' || org.type == 'faculty';
  
  final scopeType = isInstitutional ? 'Institutional' : (isFaculty ? 'Faculty' : 'Program');
  final scopeId = isInstitutional ? org.campusId : (isFaculty ? org.facultyId : org.programId);
  if (scopeId == null) return [];
  
  return ref.watch(announcementRepositoryProvider).getAnnouncementsByScope(scopeType, scopeId);
});
