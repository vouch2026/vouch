import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/quick_actions.dart';
import '../widgets/analytics/kpi_cards.dart';
import '../widgets/tables/organization_table.dart';

class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
