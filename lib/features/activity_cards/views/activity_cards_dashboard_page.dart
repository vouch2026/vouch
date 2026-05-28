import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/layouts/dashboard_layout.dart';
import '../models/activity_card_mock_data.dart';
import '../widgets/activity_card_overview_card.dart';
import '../widgets/activity_card_analytics_card.dart';

class ActivityCardsDashboardPage extends StatelessWidget {
  const ActivityCardsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'My Activity Cards',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DashboardHeader(),
            const SizedBox(height: AppSpacing.xl),
            const _AnalyticsOverview(),
            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('Organization Clearances'),
            const SizedBox(height: AppSpacing.md),
            const _ActivityCardsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track your organization clearance progress and signatures',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _AnalyticsOverview extends StatelessWidget {
  const _AnalyticsOverview();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        double aspectRatio = 3.0;

        if (constraints.maxWidth > 1400) {
          crossAxisCount = 4;
          aspectRatio = 2.0;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 2;
          aspectRatio = 2.5;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          aspectRatio = 2.0;
        }
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: aspectRatio,
          children: const [
            ActivityCardAnalyticsCard(
              label: 'Total Organizations',
              value: '2',
              icon: Icons.corporate_fare_rounded,
              color: Colors.blue,
            ),
            ActivityCardAnalyticsCard(
              label: 'Cleared Cards',
              value: '0',
              icon: Icons.verified_user_rounded,
              color: Colors.green,
            ),
            ActivityCardAnalyticsCard(
              label: 'Pending Signatures',
              value: '6',
              icon: Icons.pending_actions_rounded,
              color: Colors.orange,
            ),
            ActivityCardAnalyticsCard(
              label: 'Compliance Score',
              value: '85%',
              icon: Icons.analytics_rounded,
              color: Colors.purple,
              trend: '+5%',
            ),
          ],
        );
      },
    );
  }
}

class _ActivityCardsGrid extends StatelessWidget {
  const _ActivityCardsGrid();

  @override
  Widget build(BuildContext context) {
    final activityCards = ActivityCardMockData.studentActivityCards;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        double mainAxisExtent = 220;

        if (constraints.maxWidth > 1400) {
          crossAxisCount = 3;
          mainAxisExtent = 240;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 2;
          mainAxisExtent = 230;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
          mainAxisExtent = 220;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: activityCards.length,
          itemBuilder: (context, index) => ActivityCardOverviewCard(
            activityCard: activityCards[index],
          ),
        );
      },
    );
  }
}
