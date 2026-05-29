import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventRepository {
  final SupabaseClient _client;

  EventRepository(this._client);

  Future<List<EventModel>> getEventsByScope(String scopeType, String scopeId) async {
    final response = await _client
        .from('events')
        .select()
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId)
        .order('event_date', ascending: false);
    
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
    final response = await _client
        .from('events')
        .insert(event.toJson())
        .select('id')
        .single();
    
    return response['id'] as String;
  }

  Future<void> updateEvent(EventModel event) async {
    await _client
        .from('events')
        .update(event.toJson())
        .eq('id', event.id);
  }

  Future<void> deleteEvent(String id) async {
    await _client
        .from('events')
        .delete()
        .eq('id', id);
  }
}
