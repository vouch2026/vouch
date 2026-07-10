import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/storage_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/users_provider.dart';

class UserController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String schoolId,
    required String? campusId,
    required String? facultyId,
    required String? programId,
    required int yearLevel,
    required String role,
    String? position,
  }) async {
    state = const AsyncLoading();
    
    try {
      // Create auth user with 'active' status metadata
      await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'school_id': schoolId,
          'campus_id': campusId?.isEmpty ?? true ? null : campusId,
          'faculty_id': facultyId?.isEmpty ?? true ? null : facultyId,
          'program_id': programId?.isEmpty ?? true ? null : programId,
          'year_level': yearLevel,
          'role': role,
          'position': position,
          'status': 'active', // Automatically active as requested
        },
      );
      
      ref.invalidate(allUsersProvider);
      
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

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

  Future<bool> deleteUser(String userId) async {
    state = const AsyncLoading();
    
    try {
      await SupabaseConfig.client.rpc(
        'delete_user_entirely',
        params: {'p_user_id': userId},
      );
      
      // Invalidate provider to refresh list
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
