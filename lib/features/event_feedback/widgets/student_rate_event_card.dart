import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../events/models/event_model.dart';
import '../providers/event_feedback_provider.dart';
import '../views/rate_event_page.dart';
import 'star_rating_input.dart';

/// Student card for the Rate tab: shows the event, its average rating,
/// the student's own rating status, and a Rate/Edit action.
class StudentRateEventCard extends ConsumerStatefulWidget {
  final EventModel event;

  const StudentRateEventCard({super.key, required this.event});

  @override
  ConsumerState<StudentRateEventCard> createState() =>
      _StudentRateEventCardState();
}

class _StudentRateEventCardState extends ConsumerState<StudentRateEventCard> {
  bool _isHovered = false;

  void _openRatePage() {
    final eventId = widget.event.id;
    if (eventId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RateEventPage(event: widget.event)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventId = widget.event.id ?? '';
    final myResponseAsync = ref.watch(myResponseProvider(eventId));
    final summaryAsync = ref.watch(eventRatingSummaryProvider(eventId));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform:
            _isHovered ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
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
                  myResponseAsync.when(
                    data: (response) {
                      final rated = response != null;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (rated ? Colors.green : Colors.grey)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (rated ? Colors.green : Colors.grey)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          rated
                              ? 'RATED ★ ${response.overallRating}'
                              : 'NOT RATED',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: rated ? Colors.green : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat.yMMMMd().format(widget.event.eventDate),
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              summaryAsync.when(
                data: (summary) => Row(
                  children: [
                    StarRatingInput(
                      rating: summary.average.round(),
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      summary.count == 0
                          ? 'No ratings yet'
                          : '${summary.average.toStringAsFixed(1)} (${summary.count})',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, _) => const SizedBox.shrink(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: myResponseAsync.when(
                  data: (response) => FilledButton.icon(
                    onPressed: _openRatePage,
                    icon: Icon(
                      response == null
                          ? Icons.star_outline_rounded
                          : Icons.edit_rounded,
                      size: 16,
                    ),
                    label: Text(
                      response == null ? 'Rate Event' : 'Edit Rating',
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
                  loading: () => const SizedBox.shrink(),
                  error: (err, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
