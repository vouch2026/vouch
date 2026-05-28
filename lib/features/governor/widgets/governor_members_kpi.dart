import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class GovernorMembersKpi extends StatelessWidget {
  const GovernorMembersKpi({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: 2.5,
      children: [
        _buildKpiCard(
          context,
          title: 'Total Members',
          value: '1,248',
          icon: Icons.people_alt_rounded,
          color: Colors.blue,
          trend: '+12% from last sem',
          isTrendPositive: true,
        ),
        _buildKpiCard(
          context,
          title: 'Active Members',
          value: '1,102',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          trend: '88% of total',
        ),
        _buildKpiCard(
          context,
          title: 'Pending Approval',
          value: '45',
          icon: Icons.pending_actions_rounded,
          color: Colors.orange,
          trend: 'Requires review',
        ),
        _buildKpiCard(
          context,
          title: 'New This Month',
          value: '86',
          icon: Icons.person_add_rounded,
          color: Colors.purple,
          trend: '+5% vs prev month',
          isTrendPositive: true,
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool? isTrendPositive,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        value,
                        style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (trend != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            trend,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isTrendPositive == true
                                  ? Colors.green
                                  : (isTrendPositive == false ? Colors.red : Colors.grey[600]),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
