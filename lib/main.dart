import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/utils/offline_image_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseConfig.initialize();
  await OfflineImageCache.init();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('tasks');
  await Hive.openBox('schedules');
  await Hive.openBox('attendance_scans');
  await Hive.openBox('profile');
  await Hive.openBox('workspaces');
  await Hive.openBox('events');
  await Hive.openBox('my_scans');
  
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
    final router = ref.watch(routerProvider);

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
