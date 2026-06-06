import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../repositories/clearance_repository.dart';

final clearanceRepositoryProvider = Provider<ClearanceRepository>((ref) {
  return ClearanceRepository(SupabaseConfig.client);
});
