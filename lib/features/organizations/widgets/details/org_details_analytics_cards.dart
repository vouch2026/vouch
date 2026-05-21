import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrgDetailsAnalyticsCards extends StatelessWidget {
  const OrgDetailsAnalyticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: constraints.maxWidth > 1200 ? 1.8 : 2.5,
          children: [
            _AnalyticsCard(
              title: 'Total Members',
              value: '1,248',
              trend: 12.5,
              icon: Icons.people_alt_rounded,
              color: AppColors.primary,
            ),
            _AnalyticsCard(
              title: 'Attendance Rate',
              value: '88.4%',
              trend: 5.2,
              icon: Icons.fact_check_rounded,
              color: AppColors.success,
            ),
            _AnalyticsCard(
              title: 'Collection Rate',
              value: '92.1%',
              trend: -2.4,
              icon: Icons.payments_rounded,
              color: AppColors.warning,
            ),
            _AnalyticsCard(
              title: 'Governance Score',
              value: '95/100',
              trend: 0.8,
              icon: Icons.gavel_rounded,
              color: AppColors.info,
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final double trend;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trend > 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                _TrendIndicator(trend: trend),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final double trend;

  const _TrendIndicator({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isPositive = trend > 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '${trend.abs()}%',
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
