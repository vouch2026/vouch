import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    final bucket = dotenv.get('SUPABASE_ID_BUCKET', fallback: 'ids');

    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadOrganizationAsset({
    required String code,
    required File file,
    required bool isLogo,
  }) async {
    final extension = p.extension(file.path);
    final fileName = '${isLogo ? 'logo' : 'banner'}_${code}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'organizations/$fileName';
    final bucket = dotenv.get('SUPABASE_ORG_BUCKET', fallback: 'org-pictures');

    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadAnnouncementImage({
    required File file,
    required String title,
  }) async {
    final extension = p.extension(file.path);
    final fileName = 'announcement_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'announcements/$fileName';
    final bucket = dotenv.get('SUPABASE_ANNOUNCEMENTS_BUCKET', fallback: 'announcement-pictures');

    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadEventImage({
    required File file,
    required String eventName,
  }) async {
    final extension = p.extension(file.path);
    final fileName = 'event_${eventName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'events/$fileName';
    final bucket = dotenv.get('SUPABASE_EVENT_BUCKET', fallback: 'event-pictures');

    await _client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
