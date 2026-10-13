import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loaders/flickr_loader.dart';
import '../../../shared/layouts/dashboard_layout.dart';
import '../../auth/providers/auth_provider.dart';
import '../../events/models/event_model.dart';
import '../models/survey_model.dart';
import '../models/survey_question_model.dart';
import '../models/survey_response_model.dart';
import '../models/survey_answer_model.dart';
import '../providers/event_feedback_provider.dart';
import '../widgets/star_rating_input.dart';
import '../widgets/survey_question_input.dart';

class _LoadedData {
  final SurveyModel? survey;
  final List<SurveyQuestionModel> questions;
  final SurveyResponseModel? myResponse;
  final List<SurveyAnswerModel> myAnswers;

  const _LoadedData({
    required this.survey,
    required this.questions,
    required this.myResponse,
    required this.myAnswers,
  });
}

/// Student form to submit (or edit) a 1-5 star rating plus the officer's
/// custom survey questions for a past event.
class RateEventPage extends ConsumerStatefulWidget {
  final EventModel event;

  const RateEventPage({super.key, required this.event});

  @override
  ConsumerState<RateEventPage> createState() => _RateEventPageState();
}

class _RateEventPageState extends ConsumerState<RateEventPage> {
  late Future<_LoadedData> _loadFuture;
  int _overallRating = 0;
  final TextEditingController _commentController = TextEditingController();
  Map<String, SurveyAnswerValue> _answers = {};
  bool _formReady = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<_LoadedData> _load() async {
    final eventId = widget.event.id ?? '';
    final repo = ref.read(eventFeedbackRepositoryProvider);
    final survey = await repo.getSurveyByEvent(eventId);
    final questions =
        survey?.id == null ? <SurveyQuestionModel>[] : await repo.getQuestions(survey!.id!);
    final user = await ref.read(userProfileProvider.future);
    final myResponse = user?.id == null
        ? null
        : await repo.getResponseForUser(eventId, user!.id!);
    final myAnswers = myResponse?.id == null
        ? <SurveyAnswerModel>[]
        : await repo.getAnswers(myResponse!.id!);
    return _LoadedData(
      survey: survey,
      questions: questions,
      myResponse: myResponse,
      myAnswers: myAnswers,
    );
  }

  void _prepareForm(_LoadedData data) {
    if (_formReady) return;
    _formReady = true;
    _overallRating = data.myResponse?.overallRating ?? 0;
    _commentController.text = data.myResponse?.comment ?? '';
    _answers = {
      for (final q in data.questions)
        if (q.id != null) q.id!: const SurveyAnswerValue(),
    };
    for (final a in data.myAnswers) {
      final current = _answers[a.questionId];
      if (current == null) continue;
      _answers[a.questionId] = SurveyAnswerValue(
        text: a.answerText ?? current.text,
        option: a.answerOption ?? current.option,
        boolValue: a.answerBool ?? current.boolValue,
        rating: a.answerRating ?? current.rating,
      );
    }
  }

  Future<void> _submit(_LoadedData data) async {
    final eventId = widget.event.id;
    if (eventId == null) return;

    if (_overallRating < 1 || _overallRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating (1-5).')),
      );
      return;
    }
    for (var i = 0; i < data.questions.length; i++) {
      final q = data.questions[i];
      if (q.isRequired && !(_answers[q.id]?.isAnswered ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please answer required question ${i + 1}.')),
        );
        return;
      }
    }

    final user = ref.read(userProfileProvider).value;
    if (user?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a rating.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(eventFeedbackRepositoryProvider);
      final comment = _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim();
      final response = await repo.upsertResponse(
        surveyId: data.survey?.id,
        eventId: eventId,
        userId: user!.id!,
        overallRating: _overallRating,
        comment: comment,
      );
      if (response?.id != null) {
        for (final q in data.questions) {
          final value = _answers[q.id];
          if (value == null || !value.isAnswered) continue;
          await repo.upsertAnswer(
            responseId: response!.id!,
            questionId: q.id!,
            answerText: (value.text == null || value.text!.trim().isEmpty)
                ? null
                : value.text!.trim(),
            answerOption: value.option,
            answerBool: value.boolValue,
            answerRating:
                (value.rating == null || value.rating == 0) ? null : value.rating,
          );
        }
      }
      invalidateEventFeedback(ref, eventId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted. Thank you!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(connectivityProvider).value == false;

    return DashboardLayout(
      title: 'Rate Event',
      onBack: () {
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      child: FutureBuilder<_LoadedData>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: FlickrLoader());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Could not load rating form.'));
          }
          _prepareForm(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: AppTextStyles.headlineSmall
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      DateFormat.yMMMMd().format(widget.event.eventDate),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isOffline)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'You are offline. Ratings require an internet connection.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                Text(
                  'Overall rating *',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                StarRatingInput(
                  rating: _overallRating,
                  onChanged: (star) =>
                      setState(() => _overallRating = star),
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Comment (optional)',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Share what you thought about this event...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
                if (data.questions.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Survey questions',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(data.questions.length, (i) {
                    final q = data.questions[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: SurveyQuestionInput(
                        question: q,
                        index: i,
                        value: _answers[q.id] ?? const SurveyAnswerValue(),
                        onChanged: (value) =>
                            setState(() => _answers[q.id!] = value),
                      ),
                    );
                  }),
                ] else ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No extra survey questions for this event — your star rating and comment are enough.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: (isOffline || _isSubmitting)
                        ? null
                        : () => _submit(data),
                    icon: _isSubmitting
                        ? const SizedBox.shrink()
                        : const Icon(Icons.star_rounded),
                    label: _isSubmitting
                        ? const FlickrLoader()
                        : Text(
                            data.myResponse != null
                                ? 'Update Rating'
                                : 'Submit Rating',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}
