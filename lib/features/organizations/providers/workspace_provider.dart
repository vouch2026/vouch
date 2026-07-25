import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../repositories/organization_repository.dart';
import 'organization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/app_role.dart';

part 'workspace_provider.freezed.dart';

@freezed
abstract class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    OrganizationModel? selectedOrganization,
    OrganizationMembershipModel? activeMembership,
    AppRole? activeRole,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,
  }) = _WorkspaceState;
}

class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  final OrganizationRepository _repository;
  final Ref _ref;

  WorkspaceNotifier(this._repository, this._ref) : super(const WorkspaceState()) {
    // Listen to auth state changes to reset workspace when user logs out
    _ref.listen(authStateProvider, (previous, next) {
      final session = next.value?.session;
      if (session == null) {
        state = const WorkspaceState(isInitialized: true);
        _clearPersistedWorkspace();
      } else if (previous?.value?.session == null) {
        _loadPersistedWorkspace();
      }
    });

    // Initial load attempt if already logged in (e.g. on refresh)
    _init();
  }

  Future<void> _init() async {
    final auth = _ref.read(authStateProvider).value;
    if (auth?.session != null) {
      await _loadPersistedWorkspace();
    } else {
      // Wait for auth to resolve in the listener
      // If auth is already resolved as null, mark as initialized
      if (_ref.read(authStateProvider).hasValue && _ref.read(authStateProvider).value?.session == null) {
        state = state.copyWith(isInitialized: true);
      }
    }
  }

  Future<void> _loadPersistedWorkspace() async {
    final box = Hive.box('settings');
    final orgId = box.get('selected_organization_id');
    
    if (orgId != null) {
      try {
        final org = await _repository.getOrganizationById(orgId);
        if (org != null) {
          await selectOrganization(org, persist: false);
        }
      } catch (e) {
        debugPrint('Error loading persisted workspace: $e');
      }
    }
    
    state = state.copyWith(isInitialized: true);
  }

  void _clearPersistedWorkspace() {
    Hive.box('settings').delete('selected_organization_id');
  }

  Future<void> selectOrganization(OrganizationModel? org, {bool persist = true}) async {
    if (org == null) {
      state = const WorkspaceState(isInitialized: true);
      _clearPersistedWorkspace();
      return;
    }

    state = state.copyWith(isLoading: true, selectedOrganization: org);
    
    if (persist) {
      Hive.box('settings').put('selected_organization_id', org.id);
    }
    
    try {
      final profile = await _ref.read(userProfileProvider.future);
      if (profile == null || profile.id == null) {
        state = state.copyWith(isLoading: false, isInitialized: true);
        return;
      }

      // Check if the user is authorized to select this workspace
      final isSuperAdmin = profile.role == 'super_admin';
      if (!isSuperAdmin) {
        final userOrgs = await _repository.getUserOrganizations(profile.id!);
        final isMember = userOrgs.any((o) => o.id == org.id);
        if (!isMember) {
          state = const WorkspaceState(isInitialized: true);
          _clearPersistedWorkspace();
          debugPrint('Unauthorized workspace selection attempt: ${org.name}');
          return;
        }
      }

      final roleData = await _repository.getWorkspaceRoleAndPermissions(org.id, org.type);

      AppRole? role;
      if (roleData != null) {
        role = AppRole(
          roleName: roleData['role_name'] as String,
          hierarchyLevel: roleData['hierarchy_level'] as int,
          scopeType: org.type,
          permissions: List<String>.from(roleData['permissions'] as List),
        );
      } else {
        role = AppRole(
          roleName: 'Member',
          hierarchyLevel: 5,
          scopeType: org.type,
          permissions: ['view_events', 'view_announcements', 'view_fees', 'view_activity_cards', 'request_clearance', 'view_sanctions'],
        );
      }

      final box = Hive.box('workspaces');
      await box.put('role_${org.id}', role.toJson());

      state = state.copyWith(
        activeMembership: null,
        activeRole: role,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e, stack) {
      debugPrint('Error in selectOrganization: $e\n$stack');
      
      final box = Hive.box('workspaces');
      final cachedRoleData = box.get('role_${org.id}');
      AppRole? role;
      if (cachedRoleData != null) {
        final jsonMap = Map<String, dynamic>.from(cachedRoleData as Map);
        role = AppRole.fromJson(jsonMap);
      } else {
        role = AppRole(
          roleName: 'Member',
          hierarchyLevel: 5,
          scopeType: org.type,
          permissions: ['view_events', 'view_announcements', 'view_fees', 'view_activity_cards', 'request_clearance', 'view_sanctions'],
        );
      }

      state = state.copyWith(
        activeMembership: null,
        activeRole: role,
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  void updateSelectedOrganization(OrganizationModel org) {
    if (state.selectedOrganization?.id == org.id) {
      state = state.copyWith(selectedOrganization: org);
    }
  }
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>((ref) {
  final repository = ref.watch(organizationRepositoryProvider);
  return WorkspaceNotifier(repository, ref);
});
