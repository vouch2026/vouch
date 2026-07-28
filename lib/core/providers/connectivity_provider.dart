import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  if (kIsWeb) {
    return Stream.value(true);
  }
  
  final controller = StreamController<bool>();
  
  Future<void> checkConnection() async {
    try {
      final client = SupabaseConfig.client;
      final host = Uri.parse(client.rest.url).host;
      final result = await InternetAddress.lookup(host).timeout(const Duration(seconds: 1));
      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (!controller.isClosed) {
        controller.add(isOnline);
      }
    } catch (_) {
      if (!controller.isClosed) {
        controller.add(false);
      }
    }
  }

  // Initial check
  checkConnection();

  // Periodic check every 8 seconds
  final timer = Timer.periodic(const Duration(seconds: 8), (_) => checkConnection());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
