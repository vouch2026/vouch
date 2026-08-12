import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository(this._client);

  /// Fetch notifications relevant to the user's specific targets (Personal, Program, Faculty, Campus, Global)
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    String? programId,
    String? facultyId,
    String? campusId,
  }) async {
    final filters = <String>[];
    filters.add('notification_type.eq.global');
    filters.add('target_user_id.eq.$userId');

    if (programId != null && programId.isNotEmpty) {
      filters.add('target_program_id.eq.$programId');
    }
    if (facultyId != null && facultyId.isNotEmpty) {
      filters.add('target_faculty_id.eq.$facultyId');
    }
    if (campusId != null && campusId.isNotEmpty) {
      filters.add('target_campus_id.eq.$campusId');
    }

    final orFilter = filters.join(',');

    final response = await _client
        .from('notifications')
        .select('''
          *,
          user_notification_reads!left (
            read_at
          )
        ''')
        .or(orFilter)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      // In Supabase, if a user has read this notification, there will be a list in `user_notification_reads`.
      // We pass it to fromJson which handles detecting if that list is non-empty.
      return NotificationModel.fromJson(json);
    }).toList();
  }

  /// Mark a notification as read by creating a record in `user_notification_reads`
  Future<void> markAsRead(String notificationId, String userId) async {
    await _client.from('user_notification_reads').insert({
      'user_id': userId,
      'notification_id': notificationId,
    });
  }

  /// Mark all notifications as read for the user
  Future<void> markAllAsRead(List<String> notificationIds, String userId) async {
    if (notificationIds.isEmpty) return;
    
    final inserts = notificationIds.map((id) => {
      'user_id': userId,
      'notification_id': id,
    }).toList();

    // Use upsert to avoid duplicate errors if some are already read
    await _client.from('user_notification_reads').upsert(
      inserts,
      onConflict: 'user_id,notification_id',
    );
  }

  /// Broadcast a notification (For authorized roles like Admin/Officers)
  Future<String> sendNotification(NotificationModel notification) async {
    final data = notification.toJson();
    data.remove('id');
    data.remove('created_at');
    data.remove('updated_at');

    final response = await _client
        .from('notifications')
        .insert(data)
        .select('id')
        .single();

    return response['id'] as String;
  }
}
