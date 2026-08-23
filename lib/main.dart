import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/offline_image_cache.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'package:vouch_v2/features/attendance/providers/attendance_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      // Catch initialization errors silently during testing/development
      debugPrint('Firebase initialization failed: $e');
    }
  }

  await SupabaseConfig.initialize();
  await NotificationService.init();
  await Hive.initFlutter();
  await OfflineImageCache.init();
  await Hive.openBox('settings');
  await Hive.openBox('tasks');
  await Hive.openBox('schedules');
  await Hive.openBox('attendance_scans');
  await Hive.openBox('profile');
  await Hive.openBox('workspaces');
  await Hive.openBox('events');
  await Hive.openBox('my_scans');
  await Hive.openBox('dashboard');
  
  runApp(
    const ProviderScope(
      child: VouchApp(),
    ),
  );
}

class VouchApp extends ConsumerWidget {
  const VouchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(globalSyncProvider);
    final router = ref.watch(routerProvider);

    // Initialize Push Notifications when user logs in
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        PushNotificationService().initialize();
      }
    });

    // Run initialization on startup if user is already logged in
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      PushNotificationService().initialize();
    }

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 13/14 size as base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Vouch',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}

// stable supabase_based.sql version