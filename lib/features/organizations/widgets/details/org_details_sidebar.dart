import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OrgDetailsSidebar extends StatelessWidget {
  const OrgDetailsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPerformancePanel(context),
        const SizedBox(height: AppSpacing.lg),
        _buildActivityTimeline(context),
      ],
    );
  }

  Widget _buildPerformancePanel(BuildContext context) {
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
          children: [
            Text(
              'Performance Health',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildScoreMetric('Attendance Score', 0.88, AppColors.success),
            const SizedBox(height: AppSpacing.md),
            _buildScoreMetric('Collection Rate', 0.92, AppColors.warning),
            const SizedBox(height: AppSpacing.md),
            _buildScoreMetric('Compliance Health', 0.95, AppColors.primary),
            const Divider(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Funds', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
                    Text('₱124,500.00', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Finance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreMetric(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
            Text('${(value * 100).toInt()}%', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTimeline(BuildContext context) {
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTimelineItem(
              'Member Joined',
              'John Doe (2022-00123) joined CSS Society.',
              '2 mins ago',
              Icons.person_add_rounded,
              AppColors.primary,
            ),
            _buildTimelineItem(
              'Fee Created',
              'Membership Fee 2026 was created by Admin.',
              '1 hour ago',
              Icons.payments_rounded,
              AppColors.warning,
            ),
            _buildTimelineItem(
              'Event Published',
              'Tech Summit 2026 is now live.',
              '3 hours ago',
              Icons.event_available_rounded,
              AppColors.success,
            ),
            _buildTimelineItem(
              'Officer Assigned',
              'Jane Smith assigned as Treasurer.',
              '1 day ago',
              Icons.assignment_ind_rounded,
              AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey, fontSize: 11)),
                const SizedBox(height: 2),
                Text(time, style: AppTextStyles.labelSmall.copyWith(color: Colors.black26, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
