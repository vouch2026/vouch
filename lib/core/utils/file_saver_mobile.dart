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
      return result['isSuccess'] == true;
    } catch (e) {
      return false;
    }
  }
}
