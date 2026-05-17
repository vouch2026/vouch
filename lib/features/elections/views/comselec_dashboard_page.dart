import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/comselec_management_header.dart';
import '../widgets/election_kpi_cards.dart';
import '../widgets/election_analytics_dashboard.dart';
import '../widgets/elections_table.dart';
import '../widgets/live_election_monitoring.dart';

class ComselecDashboardPage extends StatelessWidget {
  const ComselecDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'COMSELEC Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComselecManagementHeader(),
            const SizedBox(height: AppSpacing.xl),
            const ElectionKpiCards(),
            const SizedBox(height: AppSpacing.xl),
            const ElectionAnalyticsDashboard(),
            const SizedBox(height: AppSpacing.xl),
            const LiveElectionMonitoring(),
            const SizedBox(height: AppSpacing.xl),
            Text('Election Management', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const ElectionsTable(),
          ],
        ),
      ),
    );
  }
}
