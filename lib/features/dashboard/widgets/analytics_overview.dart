import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AnalyticsOverviewSection extends StatelessWidget {
  const AnalyticsOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return const Column(
            children: [
              _ChartCard(title: 'Attendance Trends', subtitle: 'Monthly attendance rate', height: 250),
              SizedBox(height: AppSpacing.md),
              _ChartCard(title: 'Finance Analytics', subtitle: 'Payment collections', height: 250),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              flex: 2,
              child: _ChartCard(title: 'Attendance Trends', subtitle: 'Monthly attendance rate', height: 350),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 1,
              child: _ChartCard(title: 'User Activity', subtitle: 'Active users by role', height: 350),
            ),
          ],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textGrey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Spacer(),
          // Placeholder for actual charts (fl_chart, syncfusion, etc.)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Chart Data Unavailable',
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
