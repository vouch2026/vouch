import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/comselec_quick_actions.dart';
import '../widgets/comselec_kpi_cards_manager.dart';
import '../widgets/comselec_table.dart';

class ComselecsManagerPage extends ConsumerWidget {
  const ComselecsManagerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DashboardLayout(
      title: 'My COMSELEC',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ComselecQuickActions(),
            const SizedBox(height: AppSpacing.xl),
            
            // Section 1 - KPI Analytics
            Text('COMSELEC KPI Analytics', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const ComselecKpiCardsManager(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Section 2 - COMSELEC Table
            Text('All COMSELEC Branches', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const ComselecTable(),
          ],
        ),
      ),
    );
  }
}
