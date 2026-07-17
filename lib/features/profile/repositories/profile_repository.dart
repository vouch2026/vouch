import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _client.from('users').update(data).eq('id', userId);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> updateEmail(String newEmail) async {
    await _client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
  }

  Future<AuthResponse> verifyEmailChange({
    required String newEmail,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      email: newEmail,
      token: token,
      type: OtpType.emailChange,
    );
  }
}
