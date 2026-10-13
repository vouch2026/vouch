import '../models/campus_model.dart';
import '../../../core/config/supabase_config.dart';

class CampusRepository {
  final _client = SupabaseConfig.client;

  Future<List<CampusModel>> getCampuses() async {
    final response = await _client
        .from('campuses')
        .select()
        .order('name');
    
    return (response as List).map((json) => CampusModel.fromJson(json)).toList();
  }

  Future<CampusModel> createCampus(CampusModel campus,
      {String? schoolId}) async {
    final data = campus.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    // school_id column exists post-migration; harmless if column is missing
    // on older DBs only when a schoolId is actually supplied.
    if (schoolId != null && schoolId.isNotEmpty) {
      data['school_id'] = schoolId;
    }

    final response = await _client
        .from('campuses')
        .insert(data)
        .select()
        .single();
    
    return CampusModel.fromJson(response);
  }

  Future<CampusModel> updateCampus(CampusModel campus) async {
    final data = campus.toJson();
    data.remove('created_at');
    data.remove('updated_at');

    final response = await _client
        .from('campuses')
        .update(data)
        .eq('id', campus.id)
        .select()
        .single();
    
    return CampusModel.fromJson(response);
  }

  Future<void> deleteCampus(String id) async {
    await _client.from('campuses').delete().eq('id', id);
  }
}
