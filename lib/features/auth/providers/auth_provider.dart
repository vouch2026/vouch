import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../core/config/supabase_config.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseConfig.client);
});

final authStateProvider = StreamProvider.autoDispose<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider.autoDispose<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user;
});

final userProfileProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final box = Hive.box('profile');
  try {
    final profile = await ref.watch(authRepositoryProvider).getUserProfile(user.id);
    if (profile != null) {
      await box.put(user.id, profile.toJson());
    }
    return profile;
  } catch (e) {
    final cached = box.get(user.id);
    if (cached != null) {
      final jsonMap = Map<String, dynamic>.from(cached as Map);
      return UserModel.fromJson(jsonMap);
    }
    rethrow;
  }
});

final userProfileByIdProvider = FutureProvider.family.autoDispose<UserModel?, String>((ref, id) async {
  return ref.watch(authRepositoryProvider).getUserProfileById(id);
});
