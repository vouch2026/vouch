import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/quick_actions.dart';
import '../widgets/analytics/kpi_cards.dart';
import '../widgets/tables/organization_table.dart';
import '../widgets/pending_requests_panel.dart';

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
            
            // Section 2 & 5 - Organization Table & Pending Requests
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('All Organizations', style: AppTextStyles.titleLarge),
                            const SizedBox(height: AppSpacing.md),
                            const OrganizationTable(),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      const Expanded(
                        flex: 1,
                        child: PendingRequestsPanel(),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Organizations', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    const OrganizationTable(),
                    const SizedBox(height: AppSpacing.xl),
                    const PendingRequestsPanel(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
