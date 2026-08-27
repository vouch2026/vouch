import 'dart:typed_data';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class FileSaverUtil {
  static Future<bool> saveFile(Uint8List bytes, String fileName) async {
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: fileName,
      );
      if (result == null) return false;
      final isSuccess = result['isSuccess'];
      final filePath = result['filePath'];
      return isSuccess == true ||
          isSuccess == 1 ||
          isSuccess == 'true' ||
          (filePath != null && filePath.toString().isNotEmpty);
    } catch (e) {
      return false;
    }
  }
}
