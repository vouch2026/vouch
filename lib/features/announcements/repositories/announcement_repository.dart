import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';

class AnnouncementRepository {
  final SupabaseClient _client;

  AnnouncementRepository(this._client);

  Future<List<AnnouncementModel>> getAnnouncementsByScope(String scopeType, String scopeId) async {
    final response = await _client
        .from('announcements')
        .select('''
          *,
          users (
            first_name,
            last_name
          )
        ''')
        .eq('scope_type', scopeType)
        .eq('scope_id', scopeId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) {
      try {
        final model = AnnouncementModel.fromJson(json);
        final author = json['users'] as Map<String, dynamic>?;
        return model.copyWith(
          authorName: author != null ? '${author['first_name']} ${author['last_name']}' : 'System',
        );
      } catch (e) {
        // Fallback for parsing errors to see if we at least get the data
        return AnnouncementModel(
          id: json['id'] as String?,
          title: json['title'] as String? ?? 'Error parsing',
          content: json['content'] as String? ?? 'Error parsing details: $e',
          type: json['type'] as String? ?? 'General',
          scopeType: scopeType,
          scopeId: scopeId,
          academicTermId: json['academic_term_id'] as String? ?? '',
        );
      }
    }).toList();
  }

  Future<String> createAnnouncement(AnnouncementModel announcement) async {
    final data = announcement.toJson();
    
    // Remove auto-generated fields
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
        .from('announcements')
        .insert(data)
        .select('id')
        .single();
    
    return response['id'] as String;
  }

  Future<void> updateAnnouncement(AnnouncementModel announcement) async {
    if (announcement.id == null) throw Exception('Cannot update announcement without an ID');
    
    await _client
        .from('announcements')
        .update(announcement.toJson())
        .eq('id', announcement.id!);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _client
        .from('announcements')
        .delete()
        .eq('id', id);
  }
}
