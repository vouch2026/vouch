import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OfflineImageCache {
  static String? _docDirPath;

  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _docDirPath = dir.path;
    } catch (e) {
      debugPrint('Error initializing OfflineImageCache: $e');
    }
  }

  static String? _getFilePath(String url) {
    if (_docDirPath == null) return null;
    final String cleanName = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return '$_docDirPath/cached_images/$cleanName.png';
  }

  static ImageProvider? get(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    
    if (kIsWeb) {
      return NetworkImage(url);
    }

    if (url.startsWith('/') || url.startsWith('file:')) {
      return FileImage(File(url));
    }

    final filePath = _getFilePath(url);
    if (filePath != null) {
      final file = File(filePath);
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        _downloadImage(url, filePath);
      }
    }

    return NetworkImage(url);
  }

  static Future<void> _downloadImage(String url, String filePath) async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);

      final client = HttpClient();
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final List<int> bytes = [];
        await for (var chunk in response) {
          bytes.addAll(chunk);
        }
        await file.writeAsBytes(bytes);
        debugPrint('Successfully cached image offline: $url');
      }
    } catch (e) {
      debugPrint('Failed to cache image offline: $url. Error: $e');
    }
  }
}
