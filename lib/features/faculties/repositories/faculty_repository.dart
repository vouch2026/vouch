import '../models/faculty_model.dart';
import '../../../core/config/supabase_config.dart';

class FacultyRepository {
  final _client = SupabaseConfig.client;

  Future<List<FacultyModel>> getFaculties({String? campusId}) async {
    var query = _client.from('faculties').select('*, dean:users!faculties_dean_id_fkey(first_name, last_name)');
    
    if (campusId != null) {
      query = query.eq('campus_id', campusId);
    }
    
    final response = await query.order('name');
    
    return (response as List).map((json) {
      final dean = json['dean'];
      String? deanName;
      if (dean != null) {
        deanName = '${dean['first_name']} ${dean['last_name']}';
      }
      return FacultyModel.fromJson({
        ...json,
        'deanName': deanName,
      });
    }).toList();
  }

  Future<FacultyModel> createFaculty(FacultyModel faculty) async {
    final data = faculty.toJson();
    data.remove('id');
    data.remove('createdAt');
    data.remove('updatedAt');
    data.remove('deanName');

    final response = await _client
        .from('faculties')
        .insert(data)
        .select('*, dean:users!faculties_dean_id_fkey(first_name, last_name)')
        .single();
    
    final dean = response['dean'];
    String? deanName;
    if (dean != null) {
      deanName = '${dean['first_name']} ${dean['last_name']}';
    }
    return FacultyModel.fromJson({
      ...response,
      'deanName': deanName,
    });
  }

  Future<FacultyModel> updateFaculty(FacultyModel faculty) async {
    final data = faculty.toJson();
    data.remove('createdAt');
    data.remove('updatedAt');
    data.remove('deanName');

    final response = await _client
        .from('faculties')
        .update(data)
        .eq('id', faculty.id)
        .select('*, dean:users!faculties_dean_id_fkey(first_name, last_name)')
        .single();
    
    final dean = response['dean'];
    String? deanName;
    if (dean != null) {
      deanName = '${dean['first_name']} ${dean['last_name']}';
    }
    return FacultyModel.fromJson({
      ...response,
      'deanName': deanName,
    });
  }

  Future<void> deleteFaculty(String id) async {
    await _client.from('faculties').delete().eq('id', id);
  }
}
