import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../events/models/event_model.dart';
import '../providers/event_feedback_provider.dart';
import '../views/survey_builder_page.dart';
import '../views/event_responses_page.dart';

/// Officer card for the Rate tab: average rating, 5..1 breakdown bars,
/// response count, and actions to manage the survey / view results.
/// Replaces the data wiring missing from the legacy `GovernorRateEventCard`.
class OfficerRateEventCard extends ConsumerStatefulWidget {
  final EventModel event;

  const OfficerRateEventCard({super.key, required this.event});

  @override
  ConsumerState<OfficerRateEventCard> createState() =>
      _OfficerRateEventCardState();
}

class _OfficerRateEventCardState extends ConsumerState<OfficerRateEventCard> {
  bool _isHovered = false;

  void _openSurveyBuilder() {
    final eventId = widget.event.id;
    if (eventId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurveyBuilderPage(event: widget.event),
      ),
    );
  }

  void _openResults() {
    final eventId = widget.event.id;
    if (eventId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventResponsesPage(event: widget.event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventId = widget.event.id ?? '';
    final summaryAsync = ref.watch(eventRatingSummaryProvider(eventId));
    final surveyAsync = ref.watch(surveyForEventProvider(eventId));

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
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              DateFormat.yMMMMd()
                                  .format(widget.event.eventDate),
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        surveyAsync.when(
                          data: (survey) => Text(
                            survey == null
                                ? 'No survey yet'
                                : (survey.isOpen
                                    ? 'Survey open'
                                    : 'Survey closed'),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: survey == null
                                  ? Colors.grey[600]
                                  : (survey.isOpen
                                      ? Colors.green
                                      : Colors.orange),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  summaryAsync.when(
                    data: (summary) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          summary.average.toStringAsFixed(1),
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < summary.average.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${summary.count} reviews',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              summaryAsync.when(
                data: (summary) => Column(
                  children: [5, 4, 3, 2, 1].map((stars) {
                    final percent = summary.percentFor(stars);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 35,
                            child: Text(
                              '$stars ★',
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Colors.amber),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '$percent%',
                              textAlign: TextAlign.end,
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, _) => const SizedBox.shrink(),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _openSurveyBuilder,
                        icon: const Icon(Icons.quiz_outlined, size: 16),
                        label: Text(
                          'Survey',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: AppColors.primary
                                  .withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: _openResults,
                        icon: const Icon(Icons.comment_outlined, size: 16),
                        label: Text(
                          'Results',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
