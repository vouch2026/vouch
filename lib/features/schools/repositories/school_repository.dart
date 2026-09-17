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

    // Default fallback so registration dropdown is NEVER empty
    return [
      const SchoolModel(
        id: 'dorsu-default-school-id',
        name: 'Davao Oriental State University',
        code: 'DORSU',
        description: 'Main University System',
      )
    ];
  }
}
