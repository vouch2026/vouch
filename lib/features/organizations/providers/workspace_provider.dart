import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../repositories/organization_repository.dart';
import 'organization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
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

      final memberships = await _repository.getOrganizationOfficers(org.id);
      
      // Filter all memberships for this user
      final myMemberships = memberships.where((m) => m.userId == profile.id).toList();
      
      OrganizationMembershipModel? activeMembership;
      if (myMemberships.isNotEmpty) {
        // Sort by hierarchy level descending (highest role first)
        myMemberships.sort((a, b) => (b.hierarchyLevel ?? 0).compareTo(a.hierarchyLevel ?? 0));
        activeMembership = myMemberships.first;
      }

      AppRole? role;
      if (activeMembership != null && activeMembership.roleName != null) {
        role = AppRole(
          roleName: activeMembership.roleName!,
          hierarchyLevel: activeMembership.hierarchyLevel ?? 5,
          scopeType: org.type,
          permissions: activeMembership.permissions, 
        );
      } else {
        // Fallback to basic membership if not found in officers list
        role = AppRole(
          roleName: 'Member',
          hierarchyLevel: 5,
          scopeType: org.type,
          permissions: ['view_events', 'view_announcements', 'view_fees', 'view_activity_cards', 'request_clearance', 'view_sanctions'],
        );
      }

      state = state.copyWith(
        activeMembership: activeMembership,
        activeRole: role,
        isLoading: false,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isInitialized: true);
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
