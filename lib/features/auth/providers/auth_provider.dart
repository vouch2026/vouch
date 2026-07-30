import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/connectivity_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseConfig.client);
});

final authStateProvider = StreamProvider.autoDispose<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider.autoDispose<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user ?? SupabaseConfig.client.auth.currentUser;
});

final userProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  ref.keepAlive();
  final userId = ref.watch(currentUserProvider.select((user) => user?.id));
  if (userId == null) return null;
  
  final box = Hive.box('profile');
  final cached = box.get(userId);
  
  // Fast path: if connectivity provider knows we are offline, load cached instantly
  final connectivity = ref.read(connectivityProvider).value;
  if (connectivity == false) {
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return UserModel.fromJson(jsonMap);
    }
    return null;
  }

  try {
    final profile = await ref
        .watch(authRepositoryProvider)
        .getUserProfile(userId)
        .timeout(const Duration(seconds: 5)); // Increased to 5s to avoid false-positives under load
    if (profile != null) {
      await box.put(userId, profile.toJson());
    }
    return profile;
  } catch (e) {
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return UserModel.fromJson(jsonMap);
    }
    rethrow;
  }
});

final userProfileByIdProvider = FutureProvider.family.autoDispose<UserModel?, String>((ref, id) async {
  ref.keepAlive();
  return ref.watch(authRepositoryProvider).getUserProfileById(id);
});
