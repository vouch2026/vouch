import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../providers/auth_provider.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/providers/storage_provider.dart';

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => _repository.signInWithEmail(
          email: email,
          password: password,
        ));
    if (!result.hasError) {
      ref.invalidate(userProfileProvider);
      ref.invalidate(workspaceProvider);
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
    XFile? idFront,
    XFile? idBack,
  }) async {
    state = const AsyncLoading();
    
    final result = await AsyncValue.guard(() async {
      String? idFrontUrl;
      String? idBackUrl;

      if (idFront != null) {
        idFrontUrl = await ref.read(storageServiceProvider).uploadIdImage(
              identifier: email,
              file: idFront,
              isFront: true,
            );
      }

      if (idBack != null) {
        idBackUrl = await ref.read(storageServiceProvider).uploadIdImage(
              identifier: email,
              file: idBack,
              isFront: false,
            );
      }

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
          'id_front_url': idFrontUrl,
          'id_back_url': idBackUrl,
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
    final result = await AsyncValue.guard(() => _repository.verifyOTP(
          email: email,
          token: token,
          type: OtpType.signup,
        ));
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
    await _repository.signOut();
    ref.invalidate(userProfileProvider);
    ref.invalidate(workspaceProvider);
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
