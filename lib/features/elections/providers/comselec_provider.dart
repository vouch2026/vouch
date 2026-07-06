import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/comselec_repository.dart';
import '../models/comselec_model.dart';
import '../../../core/config/supabase_config.dart';

final comselecRepositoryProvider = Provider<ComselecRepository>((ref) {
  return ComselecRepository(SupabaseConfig.client);
});

final comselecsProvider = FutureProvider<List<ComselecModel>>((ref) async {
  return ref.watch(comselecRepositoryProvider).getComselecs();
});

final comselecProvider = FutureProvider.family<ComselecModel?, String>((ref, id) async {
  return ref.watch(comselecRepositoryProvider).getComselecById(id);
});
