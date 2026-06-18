import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vouch_v2/features/auth/controllers/auth_controller.dart';
import 'package:vouch_v2/features/auth/repositories/auth_repository.dart';
import 'package:vouch_v2/features/auth/providers/auth_provider.dart';
import 'package:vouch_v2/features/auth/models/user_model.dart';

class AuthRepositoryMock implements AuthRepository {
  final AuthResponse mockAuthResponse;
  final UserModel? mockUserProfile;
  bool signOutCalled = false;

  AuthRepositoryMock({
    required this.mockAuthResponse,
    required this.mockUserProfile,
  });

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return mockAuthResponse;
  }

  @override
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return mockAuthResponse;
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    return mockUserProfile;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AuthController status check tests', () {
    test('Successful login with active status', () async {
      const mockUser = User(
        id: 'active-user',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-06-17',
        email: 'active@test.com',
      );
      final mockSession = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: mockUser,
      );
      final mockResponse = AuthResponse(session: mockSession, user: mockUser);
      final mockProfile = UserModel(
        id: 'user-1',
        authId: 'active-user',
        email: 'active@test.com',
        schoolId: '2023-0001',
        status: 'active',
      );

      final repo = AuthRepositoryMock(
        mockAuthResponse: mockResponse,
        mockUserProfile: mockProfile,
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('active@test.com', 'password');

      expect(container.read(authControllerProvider).hasError, false);
      expect(repo.signOutCalled, false);
    });

    test('Failed login with pending status signs out and throws error', () async {
      const mockUser = User(
        id: 'pending-user',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-06-17',
        email: 'pending@test.com',
      );
      final mockSession = Session(
        accessToken: 'token',
        tokenType: 'bearer',
        user: mockUser,
      );
      final mockResponse = AuthResponse(session: mockSession, user: mockUser);
      final mockProfile = UserModel(
        id: 'user-2',
        authId: 'pending-user',
        email: 'pending@test.com',
        schoolId: '2023-0002',
        status: 'pending',
      );

      final repo = AuthRepositoryMock(
        mockAuthResponse: mockResponse,
        mockUserProfile: mockProfile,
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('pending@test.com', 'password');

      final state = container.read(authControllerProvider);
      expect(state.hasError, true);
      expect(state.error.toString(), contains('pending activation'));
      expect(repo.signOutCalled, true);
    });
  });
}
