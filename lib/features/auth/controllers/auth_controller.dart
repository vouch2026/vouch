import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/services/push_notification_service.dart';

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final response = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        final profile = await _repository.getUserProfile(user.id);
        if (profile == null) {
          await _repository.signOut();
          throw Exception('User profile not found.');
        }
        if (profile.status != 'active') {
          await _repository.signOut();
          if (profile.status == 'pending') {
            throw Exception('Your account is pending activation. Please contact an administrator.');
          } else {
            throw Exception('Your account is ${profile.status}. Please contact an administrator.');
          }
        }
      }
      return response;
    });
    if (!result.hasError) {
      ref.invalidate(userProfileProvider);
      ref.invalidate(workspaceProvider);
      PushNotificationService().initialize();
    }
    state = result;
  }


  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String schoolId,
    required String campusId,
    required String facultyId,
    required String programId,
    required int yearLevel,
  }) async {
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      return await _repository.signUpWithEmail(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'school_id': schoolId,
          'campus_id': campusId,
          'faculty_id': facultyId,
          'program_id': programId,
          'year_level': yearLevel,
          'role': 'student',
          'status': 'pending',
        },
      );
    });
    
    state = result;
    return !result.hasError;
  }

  Future<bool> verifyOTP({
    required String email,
    required String token,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final response = await _repository.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      final user = response.user;
      if (user != null) {
        final profile = await _repository.getUserProfile(user.id);
        if (profile == null) {
          await _repository.signOut();
          throw Exception('User profile not found.');
        }
        if (profile.status != 'active') {
          await _repository.signOut();
          if (profile.status == 'pending') {
            throw Exception('Your account is pending activation. Please contact an administrator.');
          } else {
            throw Exception('Your account is ${profile.status}. Please contact an administrator.');
          }
        }
      }
      return response;
    });
    if (!result.hasError) {
      ref.invalidate(userProfileProvider);
    }
    state = result;
    return !result.hasError;
  }

  Future<void> resendOTP(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.resendOTP(
          email: email,
          type: OtpType.signup,
        ));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await PushNotificationService().deleteTokenOnSignOut();
    } catch (e) {
      debugPrint('AuthController: Error deleting FCM token on sign out: $e');
    }
    await _repository.signOut();
    ref.invalidate(userProfileProvider);
    ref.invalidate(workspaceProvider);
    state = const AsyncData(null);
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _repository.sendPasswordResetEmail(email));
    state = result;
    return !result.hasError;
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await _repository.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      await _repository.updatePassword(newPassword);
      await _repository.signOut();
    });
    state = result;
    return !result.hasError;
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
