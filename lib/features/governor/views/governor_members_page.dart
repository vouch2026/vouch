import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../users/widgets/advanced_user_filter_panel.dart';
import '../../users/widgets/user_management_header.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../widgets/governor_members_kpi.dart';
import '../widgets/governor_members_table.dart';

class GovernorMembersPage extends ConsumerWidget {
  const GovernorMembersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(workspaceProvider);
    final activeRoleName = workspace.activeRole?.roleName.toLowerCase() ?? '';
    final canManageMembers = activeRoleName.contains('governor') || 
                            activeRoleName.contains('president') ||
                            activeRoleName.contains('vice governor') ||
                            activeRoleName.contains('vice president');

    return DashboardLayout(
      title: 'Organization Members',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final verticalGap = isMobile ? AppSpacing.lg : AppSpacing.xl;

          return SingleChildScrollView(
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
              filters: const [
                FilterOption(
                  label: 'Year Level',
                  key: 'yearLevel',
                  options: [
                    FilterValue(label: '1st Year', value: 1),
                    FilterValue(label: '2nd Year', value: 2),
                    FilterValue(label: '3rd Year', value: 3),
                    FilterValue(label: '4th Year', value: 4),
                    FilterValue(label: '5th Year', value: 5),
                  ],
                ),
                FilterOption(
                  label: 'Program',
                  key: 'program',
                  options: [
                    FilterValue(label: 'BSIT', value: 'BSIT'),
                    FilterValue(label: 'BSCS', value: 'BSCS'),
                    FilterValue(label: 'BSBA', value: 'BSBA'),
                    FilterValue(label: 'BSCrim', value: 'BSCrim'),
                  ],
                ),
                FilterOption(
                  label: 'Faculty',
                  key: 'faculty',
                  options: [
                    FilterValue(label: 'College of Engineering', value: 'COE'),
                    FilterValue(label: 'College of Arts & Sciences', value: 'CAS'),
                  ],
                ),
                FilterOption(
                  label: 'Role',
                  key: 'role',
                  options: [
                    FilterValue(label: 'Officer', value: 'officer'),
                    FilterValue(label: 'Staff', value: 'staff'),
                    FilterValue(label: 'Member', value: 'member'),
                  ],
                ),
              ],
              onSearchChanged: (query) {},
              onFiltersChanged: (filters) {},
            ),
            const SizedBox(height: AppSpacing.lg),
            
            const GovernorMembersTable(),
          ],
        ),
      );
    },
  ),
);
  }
}
