import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/models/event_model.dart';
import '../models/survey_answer_model.dart';
import '../models/survey_question_model.dart';
import '../models/survey_question_type.dart';
import '../models/survey_response_model.dart';
import '../providers/event_feedback_provider.dart';
import '../widgets/star_rating_input.dart';

/// Officer view of aggregated ratings + per-question results + all comments.
class EventResponsesPage extends ConsumerWidget {
  final EventModel event;

  const EventResponsesPage({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventId = event.id ?? '';
    final summaryAsync = ref.watch(eventRatingSummaryProvider(eventId));
    final responsesAsync = ref.watch(eventResponsesProvider(eventId));
    final surveyAsync = ref.watch(surveyForEventProvider(eventId));
    final answersAsync = ref.watch(eventAnswersProvider(eventId));

    return DashboardLayout(
      title: 'Event Results',
      onBack: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: AppTextStyles.headlineSmall
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMMd().format(event.eventDate),
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppSpacing.xl),
            summaryAsync.when(
              data: (summary) => _SummaryHeader(
                average: summary.average,
                count: summary.count,
                breakdown: summary.breakdown,
              ),
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Text('Error loading summary: $err'),
            ),
            const SizedBox(height: AppSpacing.xl),
            surveyAsync.when(
              data: (survey) {
                if (survey?.id == null) {
                  return Text(
                    'No custom survey questions for this event.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.grey[600]),
                  );
                }
                final questionsAsync =
                    ref.watch(surveyQuestionsProvider(survey!.id!));
                return questionsAsync.when(
                  data: (questions) {
                    if (questions.isEmpty) {
                      return Text(
                        'No custom survey questions for this event.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.grey[600]),
                      );
                    }
                    return answersAsync.when(
                      data: (answers) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Survey results',
                            style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...questions.map((q) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: _QuestionResultCard(
                                  question: q,
                                  answers: answers
                                      .where((a) => a.questionId == q.id)
                                      .toList(),
                                ),
                              )),
                        ],
                      ),
                      loading: () =>
                          const Center(child: FlickrLoader()),
                      error: (err, _) => Text('Error: $err'),
                    );
                  },
                  loading: () => const Center(child: FlickrLoader()),
                  error: (err, _) => Text('Error: $err'),
                );
              },
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'All comments',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            responsesAsync.when(
              data: (responses) {
                final withComments = responses
                    .where((r) =>
                        r.comment != null && r.comment!.trim().isNotEmpty)
                    .toList();
                if (withComments.isEmpty) {
                  return Text(
                    'No comments yet.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.grey[600]),
                  );
                }
                return Column(
                  children: withComments
                      .map((r) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm),
                            child: _ResponseTile(response: r),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(child: FlickrLoader()),
              error: (err, _) => Text('Error: $err'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final double average;
  final int count;
  final Map<int, int> breakdown;

  const _SummaryHeader({
    required this.average,
    required this.count,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            average.toStringAsFixed(1),
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          StarRatingInput(rating: average.round(), size: 20),
          const SizedBox(height: 4),
          Text(
            '$count review${count == 1 ? '' : 's'}',
            style:
                AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppSpacing.md),
          ...[5, 4, 3, 2, 1].map((stars) {
            final starCount = breakdown[stars] ?? 0;
            final percent =
                count == 0 ? 0 : ((starCount / count) * 100).round();
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
                        valueColor: const AlwaysStoppedAnimation<Color>(
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
          }),
        ],
      ),
    );
  }
}

class _QuestionResultCard extends StatelessWidget {
  final SurveyQuestionModel question;
  final List<SurveyAnswerModel> answers;

  const _QuestionResultCard({required this.question, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${SurveyQuestionType.label(question.questionType)} · ${answers.length} answer${answers.length == 1 ? '' : 's'}',
            style:
                AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildAggregate(context),
        ],
      ),
    );
  }

  Widget _buildAggregate(BuildContext context) {
    if (answers.isEmpty) {
      return Text(
        'No answers yet.',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
      );
    }
    switch (question.questionType) {
      case SurveyQuestionType.star:
        final ratings = answers
            .map((a) => a.answerRating)
            .whereType<int>()
            .toList();
        if (ratings.isEmpty) return const Text('No answers yet.');
        final avg = ratings.reduce((a, b) => a + b) / ratings.length;
        return Row(
          children: [
            StarRatingInput(rating: avg.round(), size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(avg.toStringAsFixed(1),
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        );
      case SurveyQuestionType.singleChoice:
        final counts = <String, int>{};
        for (final a in answers) {
          final option = a.answerOption ?? 'Other';
          counts[option] = (counts[option] ?? 0) + 1;
        }
        final total = answers.length;
        return Column(
          children: counts.entries.map((entry) {
            final percent = ((entry.value / total) * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key,
                        style: AppTextStyles.bodySmall),
                  ),
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / total,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '$percent%',
                      textAlign: TextAlign.end,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      case SurveyQuestionType.yesNo:
        final yesCount = answers.where((a) => a.answerBool == true).length;
        final noCount = answers.where((a) => a.answerBool == false).length;
        final total = answers.length;
        final yesPercent =
            total == 0 ? 0 : ((yesCount / total) * 100).round();
        return Text(
          'Yes: $yesCount ($yesPercent%) · No: $noCount',
          style: AppTextStyles.bodyMedium,
        );
      case SurveyQuestionType.text:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: answers
              .map((a) => a.answerText)
              .whereType<String>()
              .where((t) => t.trim().isNotEmpty)
              .take(10)
              .map((t) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(
                            child: Text(t,
                                style: AppTextStyles.bodySmall)),
                      ],
                    ),
                  ))
              .toList(),
        );
    }
  }
}

class _ResponseTile extends ConsumerWidget {
  final SurveyResponseModel response;

  const _ResponseTile({required this.response});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileByIdProvider(response.userId));
    final name = userAsync.when(
      data: (user) {
        if (user == null) return 'Member';
        final full = user.fullName.trim();
        return full.isEmpty ? user.email : full;
      },
      loading: () => 'Member',
      error: (err, _) => 'Member',
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              StarRatingInput(rating: response.overallRating, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            response.comment ?? '',
            style: AppTextStyles.bodySmall,
          ),
          if (response.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd().format(response.createdAt!.toLocal()),
              style: AppTextStyles.labelSmall
                  .copyWith(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}
