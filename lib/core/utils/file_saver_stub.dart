import 'dart:typed_data';

abstract class FileSaverUtil {
  static Future<bool> saveFile(Uint8List bytes, String fileName) async {
    throw UnimplementedError('saveFile() has not been implemented.');
  }
}
