import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

// --- Recent Activity Feed ---
class RecentActivityFeed extends StatelessWidget {
  const RecentActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      title: 'Recent Activity',
      actionText: 'View All',
      onAction: () {},
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (context, index) => const Divider(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          return const _ActivityItem(
            avatarText: 'JS',
            action: 'John Smith approved payment',
            time: '2 mins ago',
            organization: 'CSS Society',
          );
        },
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String avatarText;
  final String action;
  final String time;
  final String organization;

  const _ActivityItem({
    required this.avatarText,
    required this.action,
    required this.time,
    required this.organization,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            avatarText,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDark)),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(time, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
                  const SizedBox(width: 4),
                  const Text('•', style: TextStyle(color: AppColors.textGrey, fontSize: 10)),
                  const SizedBox(width: 4),
                  Text(organization, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Pending Approvals Panel ---
class PendingApprovalsPanel extends StatelessWidget {
  const PendingApprovalsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      title: 'Pending Approvals',
      actionText: 'Manage',
      onAction: () {},
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.textGrey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.textGrey.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.orange, size: 16),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student Registration', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text('Jane Doe - BSCS 1', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textGrey)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.red),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- System Health Panel ---
class SystemHealthPanel extends StatelessWidget {
  const SystemHealthPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _SidebarCard(
      title: 'System Health',
      actionText: 'Details',
      onAction: () {},
      child: Column(
        children: [
          _HealthItem(icon: Icons.dns_rounded, label: 'Server Status', value: 'Online', color: Colors.green),
          const SizedBox(height: AppSpacing.sm),
          _HealthItem(icon: Icons.storage_rounded, label: 'Database Health', value: 'Optimal', color: Colors.green),
          const SizedBox(height: AppSpacing.sm),
          _HealthItem(icon: Icons.cloud_done_rounded, label: 'Storage Usage', value: '45%', color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          _HealthItem(icon: Icons.people_alt_rounded, label: 'Active Users', value: '1,204', color: AppColors.primary),
        ],
      ),
    );
  }
}

class _HealthItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _HealthItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textGrey)),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


// --- Base Sidebar Card ---
class _SidebarCard extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget child;

  const _SidebarCard({
    required this.title,
    this.actionText,
    this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              if (actionText != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText!,
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
