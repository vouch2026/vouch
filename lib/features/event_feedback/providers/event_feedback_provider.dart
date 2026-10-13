import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/rating_summary.dart';
import '../models/survey_answer_model.dart';
import '../models/survey_model.dart';
import '../models/survey_question_model.dart';
import '../models/survey_response_model.dart';
import '../repositories/event_feedback_repository.dart';

final eventFeedbackRepositoryProvider =
    Provider<EventFeedbackRepository>((ref) {
  return EventFeedbackRepository(SupabaseConfig.client);
});

/// Survey row for an event, if an officer created one. Null = no survey yet
/// (bare star rating is still allowed).
final surveyForEventProvider =
    FutureProvider.family<SurveyModel?, String>((ref, eventId) async {
  return ref.watch(eventFeedbackRepositoryProvider).getSurveyByEvent(eventId);
});

/// Ordered custom questions for a survey.
final surveyQuestionsProvider =
    FutureProvider.family<List<SurveyQuestionModel>, String>(
        (ref, surveyId) async {
  return ref.watch(eventFeedbackRepositoryProvider).getQuestions(surveyId);
});

/// Current user's response for an event, if any.
final myResponseProvider =
    FutureProvider.family<SurveyResponseModel?, String>((ref, eventId) async {
  final user = await ref.watch(userProfileProvider.future);
  if (user?.id == null) return null;
  return ref
      .watch(eventFeedbackRepositoryProvider)
      .getResponseForUser(eventId, user!.id!);
});

/// Current user's per-question answers for an event (empty if none).
final myAnswersForEventProvider =
    FutureProvider.family<List<SurveyAnswerModel>, String>(
        (ref, eventId) async {
  final response = await ref.watch(myResponseProvider(eventId).future);
  if (response?.id == null) return [];
  return ref.watch(eventFeedbackRepositoryProvider).getAnswers(response!.id!);
});

/// Aggregated stars for an event (average, count, 5..1 breakdown).
final eventRatingSummaryProvider =
    FutureProvider.family<RatingSummary, String>((ref, eventId) async {
  final responses =
      await ref.watch(eventFeedbackRepositoryProvider).getResponses(eventId);
  return RatingSummary.fromResponses(eventId, responses);
});

/// All responses for an event (officer results view).
final eventResponsesProvider =
    FutureProvider.family<List<SurveyResponseModel>, String>(
        (ref, eventId) async {
  return ref.watch(eventFeedbackRepositoryProvider).getResponses(eventId);
});

/// All per-question answers for an event (officer results view).
final eventAnswersProvider =
    FutureProvider.family<List<SurveyAnswerModel>, String>((ref, eventId) async {
  return ref.watch(eventFeedbackRepositoryProvider).getAnswersByEvent(eventId);
});

/// Invalidates everything rate-related for one event after a submit/edit.
void invalidateEventFeedback(WidgetRef ref, String eventId) {
  ref.invalidate(myResponseProvider(eventId));
  ref.invalidate(myAnswersForEventProvider(eventId));
  ref.invalidate(eventRatingSummaryProvider(eventId));
  ref.invalidate(eventResponsesProvider(eventId));
  ref.invalidate(eventAnswersProvider(eventId));
  ref.invalidate(surveyForEventProvider(eventId));
}
