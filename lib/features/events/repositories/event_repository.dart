import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventRepository {
  final SupabaseClient _client;

  EventRepository(this._client);

  Future<List<EventModel>> getEventsByScope(
    String scopeType,
    String scopeId, {
    String? academicTermId,
  }) async {
    var query = _client
        .from('events')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId);
    if (academicTermId != null) {
      query = query.eq('academic_term_id', academicTermId);
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

  Future<String> createEvent(EventModel event) async {
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
    
    return response['id'] as String;
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

  Future<List<EventModel>> getAllEvents({String? academicTermId}) async {
    var query = _client.from('events').select();
    if (academicTermId != null) {
      query = query.eq('academic_term_id', academicTermId);
    }
    final response = await query.order('event_date', ascending: false);

    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }

  // --- Obligation targets -------------------------------------------------
  // Visibility = parent scope (everyone in scope sees the event).
  // Obligation = row in event_targets (only selected members must attend and
  // it counts toward activity-card clearance). Events with zero target rows
  // keep legacy behavior: all in scope are obligated.

  /// User ids obligated for [eventId]. Empty = legacy (all in scope).
  /// Returns [] (not error) when the table doesn't exist yet (old DB).
  Future<List<String>> getEventTargets(String eventId) async {
    try {
      final response = await _client
          .from('event_targets')
          .select('user_id')
          .eq('event_id', eventId);
      return (response as List)
          .map((row) => (row as Map)['user_id'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Replace the full target set for [eventId] (delete + bulk insert).
  /// Pass an empty list to clear back to legacy "all in scope" behavior.
  Future<void> setEventTargets(String eventId, List<String> userIds) async {
    try {
      await _client.from('event_targets').delete().eq('event_id', eventId);
      if (userIds.isEmpty) return;
      final rows = userIds
          .toSet()
          .map((uid) => {'event_id': eventId, 'user_id': uid})
          .toList();
      await _client.from('event_targets').insert(rows);
    } catch (_) {
      // Table missing on old DBs — event itself is already created; ignore.
    }
  }

  /// Event ids in [scope] for which [userId] is explicitly targeted.
  Future<Set<String>> getObligatedEventIds(
    String userId, {
    String? academicTermId,
  }) async {
    try {
      var query = _client
          .from('event_targets')
          .select('event_id, events!inner(academic_term_id)')
          .eq('user_id', userId);
      if (academicTermId != null) {
        query = query.eq('events.academic_term_id', academicTermId);
      }
      final response = await query;
      return (response as List)
          .map((row) => (row as Map)['event_id'] as String)
          .toSet();
    } catch (_) {
      return {};
    }
  }
}
