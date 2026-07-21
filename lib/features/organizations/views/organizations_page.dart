import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/quick_actions.dart';
import '../widgets/analytics/kpi_cards.dart';
import '../widgets/tables/organization_table.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/workspace_provider.dart';
import '../../../core/utils/role_mapper.dart';

class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider).value;
    final activeRole = ref.watch(workspaceProvider).activeRole;
    final isSuperAdmin = userProfile?.role == 'super_admin';

    bool isAuthorized = isSuperAdmin;
    if (!isAuthorized && activeRole != null) {
      final roleKey = RoleMapper.mapDbRoleToAppFormat(activeRole.roleName);
      if (roleKey == 'dean' || roleKey == 'program_head') {
        isAuthorized = true;
      }
    }

    if (!isAuthorized) {
      return const DashboardLayout(
        title: 'Organizations',
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: AppColors.error),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Access Denied',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'You do not have permission to view the organizations list.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DashboardLayout(
      title: 'Organizations',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QuickActions(),
            const SizedBox(height: AppSpacing.xl),
            
            // Section 1 - KPI Analytics
            Text('Organization KPI Analytics', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const KpiCards(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Section 2 - Organization Table
            Text('All Organizations', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const OrganizationTable(),
          ],
        ),
      ),
    );
  }
}
