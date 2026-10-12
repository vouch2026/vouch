import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/advanced_user_filter_panel.dart';
import '../../users/widgets/user_management_header.dart';
import '../../organizations/providers/organization_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../widgets/governor_members_kpi.dart';
import '../widgets/governor_members_table.dart';
import '../widgets/member_directory_helpers.dart';

class GovernorMembersPage extends ConsumerStatefulWidget {
  const GovernorMembersPage({super.key});

  @override
  ConsumerState<GovernorMembersPage> createState() =>
      _GovernorMembersPageState();
}

class _GovernorMembersPageState extends ConsumerState<GovernorMembersPage> {
  Timer? _debounce;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  int _filterResetToken = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChangedRaw(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = query);
    });
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() => _activeFilters = Map<String, dynamic>.of(filters));
  }

  void _clearSearchAndFilters() {
    _debounce?.cancel();
    setState(() {
      _searchQuery = '';
      _activeFilters = {};
      _filterResetToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(workspaceProvider);
    final activeRoleName = workspace.activeRole?.roleName.toLowerCase() ?? '';
    final canManageMembers = activeRoleName.contains('governor') ||
        activeRoleName.contains('president') ||
        activeRoleName.contains('vice governor') ||
        activeRoleName.contains('vice president');
    final selectedOrg = workspace.selectedOrganization;

    // Dynamic options: derived from the actual org roster so dropdowns
    // never offer programs/faculties the org doesn't have.
    final membersAsync = selectedOrg == null
        ? null
        : ref.watch(organizationMembersProvider(selectedOrg.id));
    final baseMembers = membersAsync?.valueOrNull
            ?.where((m) {
              final role = m.role.toLowerCase();
              return role == 'member' || role == 'student';
            })
            .toList() ??
        const [];
    final dynamicFilters =
        MemberDirectoryHelpers.buildMemberFilterOptions(baseMembers);

    return DashboardLayout(
      title: 'Organization Members',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final verticalGap = isMobile ? AppSpacing.lg : AppSpacing.xl;

          return RefreshIndicator(
            onRefresh: () async {
              final selectedOrg = ref.read(workspaceProvider).selectedOrganization;
              if (selectedOrg != null) {
                try {
                  // ignore: unused_result
                  await ref.refresh(
                      organizationMembersProvider(selectedOrg.id).future);
                } catch (_) {}
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserManagementHeader(
                  title: 'Members',
                  subtitle: canManageMembers
                      ? 'View and manage all members of your organization'
                      : 'View all members of your organization',
                  actions: const [],
                ),
                SizedBox(height: verticalGap),

                const GovernorMembersKpi(),
                SizedBox(height: verticalGap),

                AdvancedUserFilterPanel(
                  filters: dynamicFilters,
                  searchHint: 'Search by name, ID, or email...',
                  resetToken: _filterResetToken,
                  onSearchChanged: _onSearchChangedRaw,
                  onFiltersChanged: _onFiltersChanged,
                ),
                const SizedBox(height: AppSpacing.lg),

                GovernorMembersTable(
                  searchQuery: _searchQuery,
                  activeFilters: _activeFilters,
                  onClearFilters: _clearSearchAndFilters,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  }
}
