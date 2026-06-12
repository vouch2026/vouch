import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../events/models/event_model.dart';

class GovernorRateEventCard extends StatefulWidget {
  final EventModel event;

  const GovernorRateEventCard({super.key, required this.event});

  @override
  State<GovernorRateEventCard> createState() => _GovernorRateEventCardState();
}

class _GovernorRateEventCardState extends State<GovernorRateEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // TODO: Connect to real rating data
    const rating = 0.0;
    const reviews = 0;
    
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
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
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                        ),
                        const Text(
                          '$reviews reviews',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(height: 24),
                ..._buildRatingBreakdown({}),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.comment_outlined, size: 16),
                    label: Text(
                      'View All Comments',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  List<Widget> _buildRatingBreakdown(Map<String, int> breakdown) {
    return ['5', '4', '3', '2', '1'].map((stars) {
      final percentage = breakdown[stars] ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              child: Text(
                '$stars ★',
                style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 30,
              child: Text(
                '$percentage%',
                textAlign: TextAlign.end,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
