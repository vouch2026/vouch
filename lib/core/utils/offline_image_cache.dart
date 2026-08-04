import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';

class OfflineImageCache {
  static Future<void> init() async {
    if (!Hive.isBoxOpen('offline_images')) {
      await Hive.openBox('offline_images');
    }
  }

  static ImageProvider? get(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }

    if (kIsWeb) {
      return CachedNetworkImageProvider(url);
    }

    if (url.startsWith('/') || url.startsWith('file:')) {
      return FileImage(File(url));
    }

    try {
      final box = Hive.box('offline_images');
      if (box.containsKey(url)) {
        final data = box.get(url);
        if (data is Uint8List) {
          return MemoryImage(data);
        } else if (data is List<int>) {
          return MemoryImage(Uint8List.fromList(data));
        }
      } else {
        _downloadImage(url);
      }
    } catch (e) {
      debugPrint('Error loading cached image from Hive: $e');
    }

    return CachedNetworkImageProvider(url);
  }

  static Future<void> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final box = Hive.box('offline_images');
        await box.put(url, response.bodyBytes);
        debugPrint('Successfully cached image offline in Hive: $url');
      } else {
        debugPrint('Failed to download image: $url. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to cache image offline: $url. Error: $e');
    }
  }
}
