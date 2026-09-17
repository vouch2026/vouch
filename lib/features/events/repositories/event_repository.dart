import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../models/event_rating_model.dart';

class EventRepository {
  final SupabaseClient _client;

  EventRepository(this._client);

  Future<List<EventModel>> getEventsByScope(String scopeType, String scopeId, {String? termId}) async {
    var query = _client
        .from('events')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId);
    
    if (termId != null) {
      query = query.eq('academic_term_id', termId);
    }
    
    final response = await query.order('event_date', ascending: false);
    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  Future<EventModel?> getEventById(String id) async {
    final response = await _client
        .from('events')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return EventModel.fromJson(response);
  }

  Future<String> createEvent(EventModel event, {
    List<Map<String, dynamic>>? targetScopes,
    List<EventRatingQuestion>? ratingQuestions,
  }) async {
    final data = event.toJson();
    
    // Remove auto-generated fields if they are null/empty to allow Supabase defaults
    if (data['id'] == null || (data['id'] as String).isEmpty) {
      data.remove('id');
    }
    if (data['created_at'] == null) {
      data.remove('created_at');
    }
    if (data['updated_at'] == null) {
      data.remove('updated_at');
    }

    final response = await _client
        .from('events')
        .insert(data)
        .select('id')
        .single();
    
    final eventId = response['id'] as String;

    // Add target scopes if provided
    if (targetScopes != null && targetScopes.isNotEmpty) {
      final scopesToInsert = targetScopes.map((s) => {
        'event_id': eventId,
        'target_type': s['target_type'],
        'target_id': s['target_id'],
        'is_mandatory': s['is_mandatory'] ?? true,
      }).toList();

      await _client.from('event_target_scopes').insert(scopesToInsert);
    }

    // Add custom rating questions if provided
    if (ratingQuestions != null && ratingQuestions.isNotEmpty) {
      final questionsToInsert = ratingQuestions.map((q) => {
        'event_id': eventId,
        'question_text': q.questionText,
        'question_type': q.questionType,
        'order_index': q.orderIndex,
      }).toList();

      await _client.from('event_rating_questions').insert(questionsToInsert);
    }

    return eventId;
  }

  Future<void> updateEvent(EventModel event) async {
    if (event.id == null) throw Exception('Cannot update event without an ID');
    
    await _client
        .from('events')
        .update(event.toJson())
        .eq('id', event.id!);
  }

  Future<void> deleteEvent(String id) async {
    await _client
        .from('events')
        .delete()
        .eq('id', id);
  }

  Future<List<EventModel>> getAllEvents({String? termId}) async {
    var query = _client.from('events').select();
    if (termId != null) {
      query = query.eq('academic_term_id', termId);
    }
    final response = await query.order('event_date', ascending: false);
    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  // --- Rating & Questions Methods ---

  Future<List<EventRatingQuestion>> getEventRatingQuestions(String eventId) async {
    try {
      final response = await _client
          .from('event_rating_questions')
          .select()
          .eq('event_id', eventId)
          .order('order_index', ascending: true);
      
      return (response as List).map((json) => EventRatingQuestion.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> submitEventRatingResponse(EventRatingResponse response) async {
    await _client.from('event_rating_responses').upsert(
      response.toJson(),
      onConflict: 'event_id,student_id,question_id',
    );
  }

  Future<EventRatingSummary> getEventRatingSummary(String eventId) async {
    try {
      final response = await _client
          .from('event_rating_responses')
          .select()
          .eq('event_id', eventId);
      
      final list = response as List;
      if (list.isEmpty) {
        return const EventRatingSummary(
          averageRating: 0.0,
          totalReviews: 0,
          ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          comments: [],
        );
      }

      int sum = 0;
      final Map<int, int> dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      final List<String> comments = [];

      for (var row in list) {
        final val = row['rating_value'] as int;
        sum += val;
        dist[val] = (dist[val] ?? 0) + 1;
        final comment = row['comment'] as String?;
        if (comment != null && comment.trim().isNotEmpty) {
          comments.add(comment.trim());
        }
      }

      final avg = sum / list.length;
      return EventRatingSummary(
        averageRating: avg,
        totalReviews: list.length,
        ratingDistribution: dist,
        comments: comments,
      );
    } catch (_) {
      return const EventRatingSummary(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        comments: [],
      );
    }
  }
}
