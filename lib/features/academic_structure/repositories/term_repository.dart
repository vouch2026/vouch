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

  Future<List<AcademicTermModel>> getAccessibleTermsForUser(String userId, bool isAdmin) async {
    final allTerms = await getTerms();
    if (isAdmin || allTerms.isEmpty) {
      return allTerms;
    }

    try {
      final userResponse = await _client
          .from('users')
          .select('registered_term_id, created_at')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) return allTerms;

      final registeredTermId = userResponse['registered_term_id'] as String?;
      final createdAtStr = userResponse['created_at'] as String?;

      if (registeredTermId != null) {
        final regTerm = allTerms.where((t) => t.id == registeredTermId).firstOrNull;
        if (regTerm != null) {
          // Allow terms starting from registered term
          final regIndex = allTerms.indexOf(regTerm);
          // allTerms is ordered descending (newest to oldest), so 0..regIndex are terms >= regTerm
          return allTerms.sublist(0, regIndex + 1);
        }
      }

      if (createdAtStr != null) {
        final userCreatedAt = DateTime.parse(createdAtStr);
        return allTerms.where((term) {
          if (term.isActive) return true;
          if (term.createdAt == null) return false;
          return term.createdAt!.isAfter(userCreatedAt) || 
                 term.createdAt!.isAtSameMomentAs(userCreatedAt) ||
                 term.createdAt!.year == userCreatedAt.year;
        }).toList();
      }
    } catch (_) {
      // Fallback on failure
    }

    return allTerms;
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

