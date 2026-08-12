import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final targetIcon = _getTargetIcon();
    final targetColor = _getTargetColor();
    final categoryLabel = _getCategoryLabel();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.04),
          border: const Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Scope Icon Container
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: targetColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                targetIcon,
                color: targetColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Scope / Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: targetColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                          border: Border.all(
                            color: targetColor.withOpacity(0.24),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          categoryLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: targetColor,
                          ),
                        ),
                      ),

                      // Time Display
                      Text(
                        _formatTime(notification.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Notification Title
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Notification Content
                  Text(
                    notification.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.3,
                      color: notification.isRead ? AppColors.textGrey : AppColors.textDark.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Unread Pulse Dot Indicator
            if (!notification.isRead) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getTargetIcon() {
    switch (notification.notificationType) {
      case 'personal':
        return Icons.person;
      case 'program':
        return Icons.school;
      case 'faculty':
        return Icons.domain;
      case 'campus':
        return Icons.location_on;
      case 'global':
      default:
        return Icons.public;
    }
  }

  Color _getTargetColor() {
    switch (notification.notificationType) {
      case 'personal':
        return AppColors.info;
      case 'program':
        return AppColors.warning;
      case 'faculty':
        return AppColors.success;
      case 'campus':
        return AppColors.primary;
      case 'global':
      default:
        return AppColors.textGrey;
    }
  }

  String _getCategoryLabel() {
    final typeName = notification.notificationType;
    final cat = notification.category;
    return '${typeName.toUpperCase()} • ${cat.toUpperCase()}';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
