import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_model.dart';
import '../models/survey_question_model.dart';
import '../models/survey_response_model.dart';
import '../models/survey_answer_model.dart';

/// Supabase data layer for post-event ratings + surveys.
///
/// Tables (see `supabase/migrations/20261022_event_surveys.sql`):
/// `event_surveys`, `event_survey_questions`, `event_survey_responses`,
/// `event_survey_answers`. All methods return empty fallbacks (not throws)
/// when tables are missing on old DBs, matching [EventRepository] behavior.
class EventFeedbackRepository {
  final SupabaseClient _client;

  EventFeedbackRepository(this._client);

  // --- Surveys ----------------------------------------------------------

  Future<SurveyModel?> getSurveyByEvent(String eventId) async {
    try {
      final response = await _client
          .from('event_surveys')
          .select()
          .eq('event_id', eventId)
          .maybeSingle();
      if (response == null) return null;
      return SurveyModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<SurveyModel?> getOrCreateSurvey(
    String eventId, {
    String? createdByUserId,
  }) async {
    final existing = await getSurveyByEvent(eventId);
    if (existing != null) return existing;
    try {
      final data = <String, dynamic>{
        'event_id': eventId,
        if (createdByUserId case final createdByUserId?)
          'created_by_user_id': createdByUserId,
      };
      final response = await _client
          .from('event_surveys')
          .insert(data)
          .select()
          .single();
      return SurveyModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<void> setSurveyOpen(String surveyId, bool isOpen) async {
    try {
      await _client.from('event_surveys').update({
        'is_open': isOpen,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', surveyId);
    } catch (_) {}
  }

  // --- Questions --------------------------------------------------------

  Future<List<SurveyQuestionModel>> getQuestions(String surveyId) async {
    try {
      final response = await _client
          .from('event_survey_questions')
          .select()
          .eq('survey_id', surveyId)
          .order('sort_order', ascending: true);
      return (response as List)
          .map((json) => SurveyQuestionModel.fromJson(
              Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<SurveyQuestionModel?> createQuestion({
    required String surveyId,
    required String questionText,
    required String questionType,
    List<String> options = const [],
    bool isRequired = true,
    int sortOrder = 0,
  }) async {
    try {
      final response = await _client
          .from('event_survey_questions')
          .insert({
            'survey_id': surveyId,
            'question_text': questionText,
            'question_type': questionType,
            'options': options,
            'is_required': isRequired,
            'sort_order': sortOrder,
          })
          .select()
          .single();
      return SurveyQuestionModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateQuestion(SurveyQuestionModel question) async {
    if (question.id == null) return;
    try {
      await _client.from('event_survey_questions').update({
        'question_text': question.questionText,
        'question_type': question.questionType,
        'options': question.options,
        'is_required': question.isRequired,
        'sort_order': question.sortOrder,
      }).eq('id', question.id!);
    } catch (_) {}
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _client
          .from('event_survey_questions')
          .delete()
          .eq('id', questionId);
    } catch (_) {}
  }

  Future<void> reorderQuestions(
      String surveyId, List<String> orderedQuestionIds) async {
    for (var i = 0; i < orderedQuestionIds.length; i++) {
      try {
        await _client
            .from('event_survey_questions')
            .update({'sort_order': i})
            .eq('id', orderedQuestionIds[i])
            .eq('survey_id', surveyId);
      } catch (_) {}
    }
  }

  // --- Responses --------------------------------------------------------

  Future<List<SurveyResponseModel>> getResponses(String eventId) async {
    try {
      final response = await _client
          .from('event_survey_responses')
          .select()
          .eq('event_id', eventId)
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => SurveyResponseModel.fromJson(
              Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<SurveyResponseModel?> getResponseForUser(
      String eventId, String userId) async {
    try {
      final response = await _client
          .from('event_survey_responses')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();
      if (response == null) return null;
      return SurveyResponseModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<SurveyResponseModel?> upsertResponse({
    String? surveyId,
    required String eventId,
    required String userId,
    required int overallRating,
    String? comment,
  }) async {
    try {
      final data = <String, dynamic>{
        'event_id': eventId,
        'user_id': userId,
        'overall_rating': overallRating,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
        if (surveyId case final surveyId?) 'survey_id': surveyId,
      };
      final response = await _client
          .from('event_survey_responses')
          .upsert(data, onConflict: 'event_id,user_id')
          .select()
          .single();
      return SurveyResponseModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  // --- Answers ----------------------------------------------------------

  Future<List<SurveyAnswerModel>> getAnswers(String responseId) async {
    try {
      final response = await _client
          .from('event_survey_answers')
          .select()
          .eq('response_id', responseId);
      return (response as List)
          .map((json) => SurveyAnswerModel.fromJson(
              Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<SurveyAnswerModel>> getAnswersByEvent(String eventId) async {
    try {
      final responses = await getResponses(eventId);
      final ids = responses
          .map((r) => r.id)
          .whereType<String>()
          .toList();
      if (ids.isEmpty) return [];
      final response = await _client
          .from('event_survey_answers')
          .select()
          .filter('response_id', 'in', ids);
      return (response as List)
          .map((json) => SurveyAnswerModel.fromJson(
              Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertAnswer({
    required String responseId,
    required String questionId,
    String? answerText,
    String? answerOption,
    bool? answerBool,
    int? answerRating,
  }) async {
    try {
      await _client.from('event_survey_answers').upsert(
        {
          'response_id': responseId,
          'question_id': questionId,
          'answer_text': answerText,
          'answer_option': answerOption,
          'answer_bool': answerBool,
          'answer_rating': answerRating,
        },
        onConflict: 'response_id,question_id',
      );
    } catch (_) {}
  }
}
