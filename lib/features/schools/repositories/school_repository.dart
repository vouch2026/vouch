import '../models/school_model.dart';
import '../../../core/config/supabase_config.dart';

class SchoolRepository {
  final _client = SupabaseConfig.client;

  Future<List<SchoolModel>> getSchools() async {
    try {
      final response = await _client
          .from('schools')
          .select()
          .order('name');
      
      final list = (response as List).map((json) => SchoolModel.fromJson(json)).toList();
      if (list.isNotEmpty) {
        return list;
      }
    } catch (_) {
      // Fall through to default fallback
    }

    // Default fallback so dropdowns are NEVER empty
    return [
      const SchoolModel(
        id: 'dorsu-default-school-id',
        name: 'Davao Oriental State University',
        code: 'DORSU',
        description: 'Main University System',
      )
    ];
  }

  Future<SchoolModel> createSchool(SchoolModel school) async {
    final data = school.toJson();
    data.remove('id');
    data.remove('created_at');

    final response = await _client
        .from('schools')
        .insert(data)
        .select()
        .single();
    
    return SchoolModel.fromJson(response);
  }

  Future<SchoolModel> updateSchool(SchoolModel school) async {
    final data = school.toJson();
    data.remove('created_at');

    final response = await _client
        .from('schools')
        .update(data)
        .eq('id', school.id)
        .select()
        .single();
    
    return SchoolModel.fromJson(response);
  }

  Future<void> deleteSchool(String id) async {
    await _client.from('schools').delete().eq('id', id);
  }
}
