import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../widgets/election_analytics_dashboard.dart';

class ElectionAnalyticsPage extends StatelessWidget {
  const ElectionAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Election Analytics',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Advanced Election Analytics', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            Text('Deep-dive institutional voting trends, participation, and candidate distribution', 
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
            const SizedBox(height: AppSpacing.xl),
            const ElectionAnalyticsDashboard(),
            const SizedBox(height: AppSpacing.xl),
            
            // Additional Analytics (Placeholder)
            Text('Voting Activity Heatmap', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Card(
              child: SizedBox(
                height: 300,
                child: Center(child: Text('Activity Heatmap Visualization Placeholder')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
