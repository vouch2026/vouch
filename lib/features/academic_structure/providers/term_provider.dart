import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../models/academic_term_model.dart';
import '../repositories/term_repository.dart';

final termRepositoryProvider = Provider<TermRepository>((ref) {
  return TermRepository(SupabaseConfig.client);
});

final academicTermsProvider = FutureProvider<List<AcademicTermModel>>((ref) async {
  return ref.watch(termRepositoryProvider).getTerms();
});

final activeTermProvider = FutureProvider<AcademicTermModel?>((ref) async {
  final client = SupabaseConfig.client;
  final response = await client
      .from('academic_terms')
      .select()
      .eq('is_active', true)
      .maybeSingle();
  
  if (response == null) return null;
  return AcademicTermModel.fromJson(response);
});
