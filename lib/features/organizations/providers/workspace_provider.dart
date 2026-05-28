import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/organization_model.dart';
import '../models/organization_membership_model.dart';
import '../repositories/organization_repository.dart';
import 'organization_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../../core/models/app_role.dart';

part 'workspace_provider.freezed.dart';

@freezed
class WorkspaceState with _$WorkspaceState {
  const factory WorkspaceState({
    OrganizationModel? selectedOrganization,
    OrganizationMembershipModel? activeMembership,
    AppRole? activeRole,
    @Default(false) bool isLoading,
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
        state = const WorkspaceState();
      }
    });
  }

  Future<void> selectOrganization(OrganizationModel? org) async {
    if (org == null) {
      state = const WorkspaceState();
      return;
    }

    state = state.copyWith(isLoading: true, selectedOrganization: org);
    
    try {
      final profile = await _ref.read(userProfileProvider.future);
      if (profile == null || profile.id == null) {
        state = state.copyWith(isLoading: false);
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
      if (activeMembership?.roleName != null) {
        role = AppRole(
          roleName: activeMembership!.roleName!,
          hierarchyLevel: activeMembership.hierarchyLevel ?? 0,
          scopeType: org.type,
          permissions: [], 
        );
      } else {
        // Fallback to basic membership if not an officer
        activeMembership = OrganizationMembershipModel(
          id: '',
          organizationId: org.id,
          userId: profile.id!,
          status: 'active',
        );
        role = AppRole(
          roleName: 'Student',
          hierarchyLevel: 5,
          scopeType: org.type,
          permissions: ['request_clearance'],
        );
      }

      state = state.copyWith(
        activeMembership: activeMembership,
        activeRole: role,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>((ref) {
  final repository = ref.watch(organizationRepositoryProvider);
  return WorkspaceNotifier(repository, ref);
});
