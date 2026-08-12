import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/config/supabase_config.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(SupabaseConfig.client);
});

class NotificationController extends AsyncNotifier<List<NotificationModel>> {
  RealtimeChannel? _channel;

  @override
  FutureOr<List<NotificationModel>> build() async {
    final userProfile = await ref.watch(userProfileProvider.future);
    if (userProfile == null || userProfile.id == null) return [];

    // Subscribe to realtime updates on build
    _subscribeToRealtime(
      userId: userProfile.id!,
      programId: userProfile.programId,
      facultyId: userProfile.facultyId,
      campusId: userProfile.campusId,
    );

    // Fetch initial list
    final repo = ref.read(notificationRepositoryProvider);
    return repo.getNotifications(
      userId: userProfile.id!,
      programId: userProfile.programId,
      facultyId: userProfile.facultyId,
      campusId: userProfile.campusId,
    );
  }

  void _subscribeToRealtime({
    required String userId,
    String? programId,
    String? facultyId,
    String? campusId,
  }) {
    // Unsubscribe from old channel if any
    _channel?.unsubscribe();

    _channel = SupabaseConfig.client
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) async {
            // Check targets locally to decide if we append
            final type = payload.newRecord['notification_type'] as String?;
            final targetUser = payload.newRecord['target_user_id'] as String?;
            final targetProgram = payload.newRecord['target_program_id'] as String?;
            final targetFaculty = payload.newRecord['target_faculty_id'] as String?;
            final targetCampus = payload.newRecord['target_campus_id'] as String?;

            bool matches = false;
            if (type == 'global') {
              matches = true;
            } else if (type == 'personal' && targetUser == userId) {
              matches = true;
            } else if (type == 'program' && targetProgram == programId) {
              matches = true;
            } else if (type == 'faculty' && targetFaculty == facultyId) {
              matches = true;
            } else if (type == 'campus' && targetCampus == campusId) {
              matches = true;
            }

            if (matches) {
              final currentList = state.value ?? [];
              final newNotif = NotificationModel.fromJson(payload.newRecord);
              
              if (!currentList.any((n) => n.id == newNotif.id)) {
                state = AsyncData([newNotif, ...currentList]);
              }
            }
          },
        );
        
    _channel?.subscribe();
  }

  Future<void> markAsRead(String notificationId) async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile == null || userProfile.id == null) return;

    final repo = ref.read(notificationRepositoryProvider);
    
    // Optimistic Update
    final currentList = state.value ?? [];
    state = AsyncData(currentList.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList());

    try {
      await repo.markAsRead(notificationId, userProfile.id!);
    } catch (e) {
      // Revert if error
      state = AsyncData(currentList);
    }
  }

  Future<void> markAllAsRead() async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile == null || userProfile.id == null) return;

    final currentList = state.value ?? [];
    final unreadIds = currentList.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    // Optimistic Update
    state = AsyncData(currentList.map((n) => n.copyWith(isRead: true)).toList());

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead(unreadIds, userProfile.id!);
    } catch (e) {
      state = AsyncData(currentList);
    }
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, List<NotificationModel>>(() {
  return NotificationController();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final listAsync = ref.watch(notificationControllerProvider);
  return listAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
