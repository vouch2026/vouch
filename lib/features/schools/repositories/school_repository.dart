import '../models/school_model.dart';
import '../../../core/config/supabase_config.dart';

class SchoolRepository {
  final _client = SupabaseConfig.client;

  Future<List<SchoolModel>> getSchools() async {
    final response =
        await _client.from('schools').select().order('name');
    return (response as List)
        .map((json) => SchoolModel.fromJson(
            Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<SchoolModel?> getSchoolById(String id) async {
    final response = await _client
        .from('schools')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return SchoolModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<SchoolModel> createSchool(SchoolModel school) async {
    final response = await _client
        .from('schools')
        .insert(school.toInsertJson())
        .select()
        .single();
    return SchoolModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<SchoolModel> updateSchool(SchoolModel school) async {
    final data = school.toInsertJson();
    final response = await _client
        .from('schools')
        .update(data)
        .eq('id', school.id)
        .select()
        .single();
    return SchoolModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<void> deleteSchool(String id) async {
    // DB RESTRICTs while campuses still reference the school — surface as-is.
    await _client.from('schools').delete().eq('id', id);
  }

  /// Raw campus rows for a school (avoids touching the freezed CampusModel).
  Future<List<Map<String, dynamic>>> getCampusRowsBySchool(
      String schoolId) async {
    final response = await _client
        .from('campuses')
        .select()
        .eq('school_id', schoolId)
        .order('name');
    return (response as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
