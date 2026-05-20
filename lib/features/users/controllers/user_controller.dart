import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../providers/user_profile_provider.dart';
import '../providers/users_provider.dart';

class UserController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateStatus(String userId, String status) async {
    state = const AsyncLoading();
    
    try {
      await SupabaseConfig.client
          .from('users')
          .update({'account_status': status})
          .eq('id', userId);
      
      // Invalidate providers to refresh data
      ref.invalidate(userProfileProvider(userId));
      ref.invalidate(allUsersProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final userControllerProvider = AsyncNotifierProvider<UserController, void>(() {
  return UserController();
});
