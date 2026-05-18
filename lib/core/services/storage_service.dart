import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String> uploadIdImage({
    required String identifier,
    required File file,
    required bool isFront,
  }) async {
    final extension = p.extension(file.path);
    final fileName = '${isFront ? 'front' : 'back'}_${identifier}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'verification_ids/$fileName';

    await _client.storage.from('ids').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('ids').getPublicUrl(path);
  }
}
