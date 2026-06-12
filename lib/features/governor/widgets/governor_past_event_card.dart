import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../events/models/event_model.dart';

class GovernorPastEventCard extends StatefulWidget {
  final EventModel event;

  const GovernorPastEventCard({super.key, required this.event});

  @override
  State<GovernorPastEventCard> createState() => _GovernorPastEventCardState();
}

class _GovernorPastEventCardState extends State<GovernorPastEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered 
                ? AppColors.primary.withValues(alpha: 0.3) 
                : AppColors.primary.withValues(alpha: 0.1),
            width: _isHovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
              blurRadius: _isHovered ? 20 : 12,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.event.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat.yMMMMd().format(widget.event.eventDate),
                    style: AppTextStyles.labelMedium.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              _buildTimeRow(context, Icons.login_rounded, 'Time in:', widget.event.timeInStart),
              const SizedBox(height: AppSpacing.xs),
              _buildTimeRow(context, Icons.logout_rounded, 'Time out:', widget.event.timeOutStart),
              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'View Full Attendance Report',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, IconData icon, String label, String? time) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
          ),
          const Spacer(),
          Text(
            time ?? '-',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

