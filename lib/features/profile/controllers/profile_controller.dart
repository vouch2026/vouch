import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/storage_provider.dart';

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> updateAvatar(XFile file) async {
    state = const AsyncLoading();
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (profile == null) return false;

      final url = await ref.read(storageServiceProvider).uploadIdImage(
        identifier: profile.email,
        file: file,
        isFront: true, // Reuse existing upload logic for now, though it might need a specific folder
      );

      await ref.read(profileRepositoryProvider).updateProfile(
        userId: profile.id!,
        data: {'profile_photo_url': url},
      );

      ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateName({required String firstName, required String lastName}) async {
    state = const AsyncLoading();
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (profile == null) return false;

      await ref.read(profileRepositoryProvider).updateProfile(
        userId: profile.id!,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateYearLevel(int yearLevel) async {
    state = const AsyncLoading();
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (profile == null) return false;

      await ref.read(profileRepositoryProvider).updateProfile(
        userId: profile.id!,
        data: {'year': yearLevel},
      );

      ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      await ref.read(profileRepositoryProvider).updatePassword(newPassword);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final profileControllerProvider = AsyncNotifierProvider<ProfileController, void>(() {
  return ProfileController();
});
