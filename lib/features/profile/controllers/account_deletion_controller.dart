import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../providers/account_deletion_provider.dart';
import '../../users/providers/users_provider.dart';

class AccountDeletionController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AccountDeletionController(this._ref) : super(const AsyncData(null));

  Future<bool> submitRequest({
    required String userId,
    required String email,
    required String studentIdNumber,
    required String fullName,
    required bool acknowledgedClearance,
    required bool acknowledgedDataLoss,
  }) async {
    state = const AsyncLoading();
    try {
      await SupabaseConfig.client.from('account_deletion_requests').insert({
        'user_id': userId,
        'email': email,
        'student_id_number': studentIdNumber,
        'full_name': fullName,
        'acknowledged_clearance': acknowledgedClearance,
        'acknowledged_data_loss': acknowledgedDataLoss,
        'status': 'pending',
      });
      
      // Invalidate the student's own pending request provider
      _ref.invalidate(myPendingDeletionRequestProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteRequestAndUser({
    required String userId,
  }) async {
    state = const AsyncLoading();
    try {
      // Call the RPC that purges the user. 
      // This will cascade delete any references in tables with ON DELETE CASCADE,
      // which includes the account_deletion_requests record.
      await SupabaseConfig.client.rpc(
        'delete_user_entirely',
        params: {'p_user_id': userId},
      );
      
      // Invalidate providers to refresh tables
      _ref.invalidate(accountDeletionRequestsProvider);
      _ref.invalidate(allUsersProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> rejectRequest(String requestId) async {
    state = const AsyncLoading();
    try {
      await SupabaseConfig.client
          .from('account_deletion_requests')
          .delete()
          .eq('id', requestId);
      
      // Invalidate list provider to refresh the admin table
      _ref.invalidate(accountDeletionRequestsProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> bulkApproveAndDelete(List<String> userIds) async {
    state = const AsyncLoading();
    bool allSuccess = true;
    for (final userId in userIds) {
      try {
        await SupabaseConfig.client.rpc(
          'delete_user_entirely',
          params: {'p_user_id': userId},
        );
      } catch (e) {
        allSuccess = false;
      }
    }
    _ref.invalidate(accountDeletionRequestsProvider);
    _ref.invalidate(allUsersProvider);
    state = const AsyncData(null);
    return allSuccess;
  }

  Future<bool> bulkReject(List<String> requestIds) async {
    state = const AsyncLoading();
    try {
      await SupabaseConfig.client
          .from('account_deletion_requests')
          .delete()
          .inFilter('id', requestIds);
      
      _ref.invalidate(accountDeletionRequestsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final accountDeletionControllerProvider =
    StateNotifierProvider<AccountDeletionController, AsyncValue<void>>((ref) {
  return AccountDeletionController(ref);
});
