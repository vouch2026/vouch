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
import '../widgets/governor_officers_table.dart';
import '../widgets/member_directory_helpers.dart';

class GovernorOfficersPage extends ConsumerStatefulWidget {
  const GovernorOfficersPage({super.key});

  @override
  ConsumerState<GovernorOfficersPage> createState() =>
      _GovernorOfficersPageState();
}

class _GovernorOfficersPageState extends ConsumerState<GovernorOfficersPage> {
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

    final membersAsync = selectedOrg == null
        ? null
        : ref.watch(organizationMembersProvider(selectedOrg.id));
    final baseOfficers = membersAsync?.valueOrNull
            ?.where((m) {
              final role = m.role.toLowerCase();
              return role != 'member' && role != 'student';
            })
            .toList() ??
        const [];
    final dynamicFilters =
        MemberDirectoryHelpers.buildOfficerFilterOptions(baseOfficers);

    return DashboardLayout(
      title: 'Organization Officers',
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
                  await ref.refresh(organizationMembersProvider(selectedOrg.id).future);
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
                    title: 'Officers',
                    subtitle: canManageMembers
                        ? 'View and manage all officers of your organization'
                        : 'View all officers of your organization',
                    actions: const [],
                  ),
                  SizedBox(height: verticalGap),

                  const GovernorMembersKpi(isOfficersScreen: true),
                  SizedBox(height: verticalGap),

                  AdvancedUserFilterPanel(
                    filters: dynamicFilters,
                    searchHint: 'Search by name, ID, or email...',
                    resetToken: _filterResetToken,
                    onSearchChanged: _onSearchChangedRaw,
                    onFiltersChanged: _onFiltersChanged,
                  ),
                  SizedBox(height: verticalGap),

                  GovernorOfficersTable(
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
