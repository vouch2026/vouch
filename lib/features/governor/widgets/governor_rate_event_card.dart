import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class GovernorRateEventCard extends StatefulWidget {
  final Map<String, dynamic> event;

  const GovernorRateEventCard({super.key, required this.event});

  @override
  State<GovernorRateEventCard> createState() => _GovernorRateEventCardState();
}

class _GovernorRateEventCardState extends State<GovernorRateEventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = (widget.event['rating'] ?? 0.0) as double;
    final reviews = widget.event['reviews'] ?? 0;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 8 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isHovered ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
              width: _isHovered ? 1.5 : 1,
            ),
          ),
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
                            widget.event['name'] ?? 'Event',
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
                                widget.event['date'] ?? '',
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
                        Text(
                          '$reviews reviews',
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Divider(height: 24),
                ..._buildRatingBreakdown(widget.event['ratingBreakdown'] as Map<String, int>? ?? {}),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.comment_outlined, size: 16),
                    label: const Text('View All Comments'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
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
