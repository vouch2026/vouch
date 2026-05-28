import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/activity_card_models.dart';
import '../../../../routes/route_paths.dart';

class ActivityCardOverviewCard extends StatelessWidget {
  final ActivityCard activityCard;

  const ActivityCardOverviewCard({
    super.key,
    required this.activityCard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedEvents = activityCard.events.where((e) => e.attendanceStatus == AttendanceStatus.completed).length;
    final totalEvents = activityCard.events.length;
    final signedSignatures = activityCard.signatures.where((s) => s.status == SignatureStatus.signed).length;
    final totalSignatures = activityCard.signatures.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: () => context.push('${RoutePaths.activityCards}/${activityCard.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        activityCard.organizationName[0],
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activityCard.organizationName,
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          activityCard.organizationType,
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: activityCard.status),
                ],
              ),
              const Spacer(),
              _ProgressInfo(
                label: 'Mandatory Events',
                current: completedEvents,
                total: totalEvents,
                icon: Icons.event_available_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ProgressInfo(
                label: 'Signatures',
                current: signedSignatures,
                total: totalSignatures,
                icon: Icons.draw_rounded,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: activityCard.completionPercentage,
                        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(activityCard.completionPercentage),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '${(activityCard.completionPercentage * 100).toInt()}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(activityCard.completionPercentage),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.7) return AppColors.primary;
    if (percentage >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

class _StatusBadge extends StatelessWidget {
  final ActivityCardStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ActivityCardStatus.cleared:
        color = Colors.green;
        label = 'CLEARED';
        break;
      case ActivityCardStatus.partiallySigned:
        color = AppColors.primary;
        label = 'PARTIALLY SIGNED';
        break;
      case ActivityCardStatus.rejected:
        color = Colors.red;
        label = 'REJECTED';
        break;
      case ActivityCardStatus.inReview:
        color = Colors.blue;
        label = 'IN REVIEW';
        break;
      default:
        color = Colors.orange;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ProgressInfo extends StatelessWidget {
  final String label;
  final int current;
  final int total;
  final IconData icon;

  const _ProgressInfo({
    required this.label,
    required this.current,
    required this.total,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          '$current/$total',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
