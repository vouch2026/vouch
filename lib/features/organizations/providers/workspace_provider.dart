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

  WorkspaceNotifier(this._repository, this._ref) : super(const WorkspaceState());

  Future<void> selectOrganization(OrganizationModel? org) async {
    if (org == null) {
      state = const WorkspaceState();
      return;
    }

    state = state.copyWith(isLoading: true, selectedOrganization: org);
    
    try {
      final profile = _ref.read(userProfileProvider).value;
      if (profile == null || profile.id == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final memberships = await _repository.getOrganizationOfficers(org.id);
      final myMembership = memberships.firstWhere(
        (m) => m.userId == profile.id,
        orElse: () => OrganizationMembershipModel(
          id: '',
          organizationId: org.id,
          userId: profile.id!,
          status: 'active',
        ),
      );

      AppRole? role;
      if (myMembership.roleName != null) {
        role = AppRole(
          roleName: myMembership.roleName!,
          hierarchyLevel: myMembership.hierarchyLevel ?? 0,
          scopeType: org.type,
          permissions: [], 
        );
      } else {
        role = AppRole(
          roleName: 'Student',
          hierarchyLevel: 5,
          scopeType: org.type,
          permissions: ['request_clearance'],
        );
      }

      state = state.copyWith(
        activeMembership: myMembership,
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
