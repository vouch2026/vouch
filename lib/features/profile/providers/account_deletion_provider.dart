import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/account_deletion_request.dart';

/// Provider to fetch all account deletion requests (Super Admin view)
final accountDeletionRequestsProvider = FutureProvider.autoDispose<List<AccountDeletionRequest>>((ref) async {
  final response = await SupabaseConfig.client
      .from('account_deletion_requests')
      .select()
      .order('created_at', ascending: false);
  return (response as List).map((json) => AccountDeletionRequest.fromJson(json)).toList();
});

/// Provider to check if the current user has a pending deletion request
final myPendingDeletionRequestProvider = FutureProvider.autoDispose<AccountDeletionRequest?>((ref) async {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null || profile.id == null) return null;
  
  final response = await SupabaseConfig.client
      .from('account_deletion_requests')
      .select()
      .eq('user_id', profile.id!)
      .eq('status', 'pending')
      .maybeSingle();
  if (response == null) return null;
  return AccountDeletionRequest.fromJson(response);
});
