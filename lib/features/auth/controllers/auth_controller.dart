import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../providers/auth_provider.dart';

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.signInWithEmail(
          email: email,
          password: password,
        ));
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String schoolId,
    required String faculty,
    required String program,
    required int yearLevel,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.signUpWithEmail(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'school_id': schoolId,
            'faculty': faculty,
            'program': program,
            'year_level': yearLevel,
            'role': 'student',
            'status': 'pending',
          },
        ));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.signOut());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
