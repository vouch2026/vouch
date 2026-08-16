import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
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
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('PushNotificationService: Foreground message received: ${message.notification?.title}');
        });

        // 5. Handle tapping notification when app is in background/terminated
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('PushNotificationService: Notification opened app: ${message.data}');
          final route = message.data['action_route'];
          if (route != null) {
            // Trigger GoRouter navigation to navigate student to specific route
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
      final response = await _supabase.from('user_fcm_tokens').upsert({
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
