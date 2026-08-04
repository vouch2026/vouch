import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

enum ImageTransactionType { receipt, profile, announcement, highlight, excuse, event, logo, banner }

class ImageCompressionService {
  static Future<Uint8List?> compressImage({
    required Uint8List bytes,
    required ImageTransactionType type,
  }) async {
    int minWidth;
    int minHeight;
    int quality;

    switch (type) {
      case ImageTransactionType.profile:
      case ImageTransactionType.logo:
        minWidth = 512;
        minHeight = 512;
        quality = 80;
        break;
      case ImageTransactionType.receipt:
      case ImageTransactionType.excuse:
        minWidth = 1200;
        minHeight = 1600;
        quality = 70;
        break;
      case ImageTransactionType.announcement:
      case ImageTransactionType.highlight:
      case ImageTransactionType.event:
        minWidth = 1080;
        minHeight = 1080;
        quality = 75;
        break;
      case ImageTransactionType.banner:
        minWidth = 1200;
        minHeight = 600;
        quality = 75;
        break;
    }

    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: CompressFormat.webp,
      );
      return result;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }
}
