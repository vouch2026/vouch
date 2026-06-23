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

  Future<List<EventModel>> getAllEvents() async {
    final response = await _client
        .from('events')
        .select()
        .order('event_date', ascending: false);
    
    return (response as List).map((json) => EventModel.fromJson(json)).toList();
  }
}
