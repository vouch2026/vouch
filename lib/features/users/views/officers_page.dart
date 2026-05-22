import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes/route_paths.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/user_management_header.dart';
import '../widgets/user_kpi_cards.dart';

class OfficersPage extends StatelessWidget {
  const OfficersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Governance Officers',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              child: Row(
                children: [
                  Icon(Icons.people_outline_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.go(RoutePaths.users),
                    child: Text('Users', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textGrey.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text('Officers', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserManagementHeader(
                    title: 'Officers',
                    subtitle: 'Monitor organization officers, governance roles, and active accounts',
                    actions: [
                      HeaderActionButton(
                        icon: Icons.admin_panel_settings_rounded,
                        label: 'Manage Roles',
                        onPressed: () {},
                        isPrimary: true,
                      ),
                      HeaderActionButton(
                        icon: Icons.file_download_outlined,
                        label: 'Export Data',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const UserKpiCards(),
                  const SizedBox(height: AppSpacing.xl),
                  
                  const Card(
                    child: SizedBox(
                      height: 400,
                      child: Center(child: Text('Governance Access Panel Placeholder')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
