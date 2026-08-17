import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../features/settings/models/settings_model.dart';
import '../../routes/app_router.dart';
import 'notification_service.dart';

class PushNotificationService {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    debugPrint('PushNotificationService: Initializing...');
    // Web is bypassed for FCM unless you have a service worker (firebase-messaging-sw.js)
    if (kIsWeb) {
      debugPrint('PushNotificationService: FCM is not supported on web in this setup.');
      return;
    }

    try {
      // 1. Request permissions for iOS / Android 13+
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('PushNotificationService: Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Fetch and register Token
        String? token = await _fcm.getToken();
        debugPrint('PushNotificationService: Fetched FCM Token: $token');
        if (token != null) {
          await _saveTokenToDatabase(token);
        }

        // 3. Listen to token refreshes
        _fcm.onTokenRefresh.listen((newToken) {
          debugPrint('PushNotificationService: Token refreshed: $newToken');
          _saveTokenToDatabase(newToken);
        });

        // 4. Handle incoming foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          debugPrint('PushNotificationService: Foreground message received: ${message.notification?.title}');
          
          final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
          final body = message.notification?.body ?? message.data['body'] ?? '';
          final category = message.data['category'] as String? ?? 'general';
          final route = message.data['action_route'] as String?;

          // Check user preferences from Hive
          bool enabled = true;
          try {
            final box = Hive.box('settings');
            final rawData = box.get('app_settings_data');
            if (rawData != null) {
              final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawData as Map);
              final settings = AppSettings.fromJson(jsonMap);
              
              if (!settings.notificationsEnabled) {
                enabled = false;
              } else if (category == 'announcement' && !settings.announcementNotifications) {
                enabled = false;
              } else if (category == 'finance' && !settings.financeNotifications) {
                enabled = false;
              }
            }
          } catch (e) {
            debugPrint('PushNotificationService: Error reading user preferences: $e');
          }

          if (!enabled) {
            debugPrint('PushNotificationService: Notification category "$category" is disabled by user settings.');
            return;
          }

          // Map category to channel
          String channelId = 'general_channel';
          if (category == 'event') {
            channelId = 'events_channel';
          } else if (category == 'finance') {
            channelId = 'fees_channel';
          } else if (category == 'announcement') {
            channelId = 'announcements_channel';
          }

          // Map category to route fallback if route is null
          String? targetRoute = route;
          if (targetRoute == null || targetRoute.isEmpty) {
            if (category == 'event') {
              targetRoute = '/workspace/events';
            } else if (category == 'finance') {
              targetRoute = '/workspace/fees';
            } else if (category == 'announcement') {
              targetRoute = '/workspace/announcements';
            } else {
              targetRoute = '/notifications';
            }
          }

          await NotificationService.showImmediateNotification(
            id: message.hashCode,
            title: title,
            body: body,
            channelId: channelId,
            payload: targetRoute,
          );
        });

        // 5. Handle tapping notification when app is in background/terminated
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('PushNotificationService: Notification opened app: ${message.data}');
          String? route = message.data['action_route'] as String?;
          final category = message.data['category'] as String? ?? 'general';
          
          if (route == null || route.isEmpty) {
            if (category == 'event') {
              route = '/workspace/events';
            } else if (category == 'finance') {
              route = '/workspace/fees';
            } else if (category == 'announcement') {
              route = '/workspace/announcements';
            } else {
              route = '/notifications';
            }
          }

          try {
            final context = rootNavigatorKey.currentContext;
            if (context != null && context.mounted) {
              context.go(route);
            } else {
              NotificationService.pendingNotificationPath = route;
            }
          } catch (e) {
            debugPrint('Error navigating from background notification tap: $e');
          }
        });
      } else {
        debugPrint('PushNotificationService: User denied notification permissions.');
      }
    } catch (e) {
      debugPrint('PushNotificationService: Error during initialization: $e');
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    if (kIsWeb) return;
    final user = _supabase.auth.currentUser;
    debugPrint('PushNotificationService: Attempting to save token to database. User: ${user?.id}');
    if (user == null) return;

    try {
      await _supabase.from('user_fcm_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token');
      debugPrint('PushNotificationService: Successfully saved token to Supabase database.');
    } catch (e) {
      debugPrint('PushNotificationService: Error saving token to Supabase: $e');
    }
  }
}
