import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../core/utils/role_mapper.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  Future<void> resendOTP({
    required String email,
    required OtpType type,
  }) async {
    await _client.auth.resend(
      email: email,
      type: type,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getUserProfileById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('''
            *,
            user_roles:user_roles!user_roles_user_id_fkey(roles(name, hierarchy_level)),
            program:programs!users_program_id_fkey(name),
            faculty:faculties!users_faculty_id_fkey(name)
          ''')
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) return null;

      final userData = Map<String, dynamic>.from(response);
      
      // Extract join names
      if (userData['program'] != null) {
        userData['programName'] = userData['program']['name'];
      }
      if (userData['faculty'] != null) {
        userData['facultyName'] = userData['faculty']['name'];
      }
      
      // Handle role extraction from the joined tables
      final userRoles = userData['user_roles'] as List?;
      String role = 'student';
      if (userRoles != null && userRoles.isNotEmpty) {
        try {
          // Sort by hierarchy level descending to get the highest role
          final sortedRoles = List.from(userRoles);
          sortedRoles.sort((a, b) {
            final rolesA = a['roles'] as Map?;
            final rolesB = b['roles'] as Map?;
            if (rolesA == null || rolesB == null) return 0;
            final levelA = (rolesA['hierarchy_level'] as num?)?.toInt() ?? 0;
            final levelB = (rolesB['hierarchy_level'] as num?)?.toInt() ?? 0;
            return levelB.compareTo(levelA);
          });
          
          final topRole = sortedRoles.first['roles'] as Map?;
          if (topRole != null) {
            role = RoleMapper.mapDbRoleToAppFormat(topRole['name'] as String);
          }
        } catch (e) {
          debugPrint('Error sorting roles: $e');
        }
      }
      
      userData['role'] = role;
      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('Error in getUserProfileById: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('''
            *,
            user_roles:user_roles!user_roles_user_id_fkey(roles(name, hierarchy_level)),
            program:programs!users_program_id_fkey(name),
            faculty:faculties!users_faculty_id_fkey(name)
          ''')
          .eq('auth_id', userId)
          .maybeSingle();
      
      if (response == null) return null;

      final userData = Map<String, dynamic>.from(response);
      
      // Extract join names
      if (userData['program'] != null) {
        userData['programName'] = userData['program']['name'];
      }
      if (userData['faculty'] != null) {
        userData['facultyName'] = userData['faculty']['name'];
      }
      
      // Handle role extraction from the joined tables
      final userRoles = userData['user_roles'] as List?;
      String role = 'student';
      if (userRoles != null && userRoles.isNotEmpty) {
        try {
          // Sort by hierarchy level descending to get the highest role
          final sortedRoles = List.from(userRoles);
          sortedRoles.sort((a, b) {
            final rolesA = a['roles'] as Map?;
            final rolesB = b['roles'] as Map?;
            if (rolesA == null || rolesB == null) return 0;
            final levelA = (rolesA['hierarchy_level'] as num?)?.toInt() ?? 0;
            final levelB = (rolesB['hierarchy_level'] as num?)?.toInt() ?? 0;
            return levelB.compareTo(levelA);
          });
          
          final topRole = sortedRoles.first['roles'] as Map?;
          if (topRole != null) {
            role = RoleMapper.mapDbRoleToAppFormat(topRole['name'] as String);
          }
        } catch (e) {
          debugPrint('Error sorting roles: $e');
        }
      }
      
      userData['role'] = role;
      return UserModel.fromJson(userData);
    } catch (e) {
      debugPrint('Error in getUserProfile: $e');
      rethrow;
    }
  }

  /// Checks if an email is already registered in the users table.
  Future<bool> isEmailRegistered(String email) async {
    try {
      final response = await _client
          .from('users')
          .select('email')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Error checking email registration: $e');
      return false;
    }
  }
}
