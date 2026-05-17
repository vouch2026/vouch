import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/campus_quick_actions.dart';
import '../widgets/academic_kpi_cards.dart';
import '../widgets/academic_analytics_panel.dart';
import '../widgets/academic_hierarchy_tree.dart';
import '../widgets/campus_table.dart';

class CampusesPage extends StatelessWidget {
  const CampusesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Campus Management',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),
            const CampusQuickActions(),
            const SizedBox(height: AppSpacing.xl),
            Text('Academic KPI Analytics', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const AcademicKpiCards(),
            const SizedBox(height: AppSpacing.xl),
            const AcademicAnalyticsPanel(),
            const SizedBox(height: AppSpacing.xl),
            
            // Section 2 - Hierarchy View
            Text('Academic Hierarchy Structure', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const AcademicHierarchyTree(),
            const SizedBox(height: AppSpacing.xl),
            
            // Section 3 - Campus Table
            Text('All Campuses', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const CampusTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage campuses, faculties, programs, and academic leadership',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
