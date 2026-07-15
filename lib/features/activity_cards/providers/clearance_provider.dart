import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../repositories/clearance_repository.dart';

final clearanceRepositoryProvider = Provider<ClearanceRepository>((ref) {
  return ClearanceRepository(SupabaseConfig.client);
});

final clearanceOrgProvider = FutureProvider.family<String?, String>((ref, requestId) async {
  if (requestId.startsWith('temp-')) return null;
  final response = await SupabaseConfig.client
      .from('activity_card_clearance_requests')
      .select('organization_id')
      .eq('id', requestId)
      .maybeSingle();
  return response?['organization_id'] as String?;
});
