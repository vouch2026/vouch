import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
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
    );
  }
}
