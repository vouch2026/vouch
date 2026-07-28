import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../models/academic_term_model.dart';
import '../repositories/term_repository.dart';
import '../../../core/providers/connectivity_provider.dart';

final termRepositoryProvider = Provider<TermRepository>((ref) {
  return TermRepository(SupabaseConfig.client);
});

final academicTermsProvider = FutureProvider<List<AcademicTermModel>>((ref) async {
  return ref.watch(termRepositoryProvider).getTerms();
});

final activeTermProvider = FutureProvider<AcademicTermModel?>((ref) async {
  final box = Hive.box('settings');
  const cacheKey = 'active_academic_term';
  final cached = box.get(cacheKey);

  // Fast path: if connectivity provider knows we are offline, load cached instantly
  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return AcademicTermModel.fromJson(jsonMap);
    }
    return null;
  }

  try {
    final client = SupabaseConfig.client;
    final response = await client
        .from('academic_terms')
        .select()
        .eq('is_active', true)
        .limit(1)
        .maybeSingle()
        .timeout(const Duration(seconds: 2));
    
    if (response == null) {
      await box.delete(cacheKey);
      return null;
    }
    
    final term = AcademicTermModel.fromJson(response);
    await box.put(cacheKey, term.toJson());
    return term;
  } catch (e) {
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return AcademicTermModel.fromJson(jsonMap);
    }
    return null;
  }
});
