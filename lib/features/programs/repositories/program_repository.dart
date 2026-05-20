import '../models/program_model.dart';
import '../../../core/config/supabase_config.dart';

class ProgramRepository {
  final _client = SupabaseConfig.client;

  Future<List<ProgramModel>> getPrograms({String? facultyId}) async {
    var query = _client.from('programs').select('*, head:users!programs_program_head_id_fkey(first_name, last_name)');
    
    if (facultyId != null) {
      query = query.eq('faculty_id', facultyId);
    }
    
    final response = await query.order('name');
    
    return (response as List).map((json) {
      final head = json['head'];
      String? programHeadName;
      if (head != null) {
        programHeadName = '${head['first_name']} ${head['last_name']}';
      }
      return ProgramModel.fromJson({
        ...json,
        'programHeadName': programHeadName,
      });
    }).toList();
  }

  Future<ProgramModel> createProgram(ProgramModel program) async {
    final data = program.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('status');
    data.remove('programHeadName');

    final response = await _client
        .from('programs')
        .insert(data)
        .select('*, head:users!programs_program_head_id_fkey(first_name, last_name)')
        .single();
    
    final head = response['head'];
    String? programHeadName;
    if (head != null) {
      programHeadName = '${head['first_name']} ${head['last_name']}';
    }
    return ProgramModel.fromJson({
      ...response,
      'programHeadName': programHeadName,
    });
  }

  Future<ProgramModel> updateProgram(ProgramModel program) async {
    final data = program.toJson();
    data.remove('created_at');
    data.remove('updated_at');
    data.remove('status');
    data.remove('programHeadName');

    final response = await _client
        .from('programs')
        .update(data)
        .eq('id', program.id)
        .select('*, head:users!programs_program_head_id_fkey(first_name, last_name)')
        .single();
    
    final head = response['head'];
    String? programHeadName;
    if (head != null) {
      programHeadName = '${head['first_name']} ${head['last_name']}';
    }
    return ProgramModel.fromJson({
      ...response,
      'programHeadName': programHeadName,
    });
  }

  Future<void> deleteProgram(String id) async {
    await _client.from('programs').delete().eq('id', id);
  }
}
