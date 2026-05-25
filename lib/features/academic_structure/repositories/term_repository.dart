import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/academic_term_model.dart';

class TermRepository {
  final SupabaseClient _client;

  TermRepository(this._client);

  Future<List<AcademicTermModel>> getTerms() async {
    final response = await _client
        .from('academic_terms')
        .select()
        .order('academic_year', ascending: false)
        .order('semester', ascending: false);
    
    return (response as List).map((json) => AcademicTermModel.fromJson(json)).toList();
  }

  Future<void> createTerm({
    required String academicYear,
    required String semester,
    bool isActive = false,
  }) async {
    await _client.from('academic_terms').insert({
      'academic_year': academicYear,
      'semester': semester,
      'is_active': isActive,
    });
  }

  Future<void> setActiveTerm(String id) async {
    // The database trigger ensure_single_active_term handles deactivating others
    await _client
        .from('academic_terms')
        .update({'is_active': true})
        .eq('id', id);
  }

  Future<void> deleteTerm(String id) async {
    await _client.from('academic_terms').delete().eq('id', id);
  }
}
