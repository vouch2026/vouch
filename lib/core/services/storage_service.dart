import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String> uploadIdImage({
    required String identifier,
    required XFile file,
    required bool isFront,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = '${isFront ? 'front' : 'back'}_${identifier}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'verification_ids/$fileName';
    final bucket = dotenv.get('SUPABASE_ID_BUCKET', fallback: 'ids');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadOrganizationAsset({
    required String code,
    required XFile file,
    required bool isLogo,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = '${isLogo ? 'logo' : 'banner'}_${code}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'organizations/$fileName';
    final bucket = dotenv.get('SUPABASE_ORG_BUCKET', fallback: 'org-pictures');

    final contentType = extension.toLowerCase() == '.png'
        ? 'image/png'
        : (extension.toLowerCase() == '.gif' ? 'image/gif' : 'image/jpeg');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadAcademicAsset({
    required String code,
    required XFile file,
    required String type,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = '${type}_logo_${code.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'academic/$fileName';
    final bucket = dotenv.get('SUPABASE_ORG_BUCKET', fallback: 'org-pictures');

    final contentType = extension.toLowerCase() == '.png'
        ? 'image/png'
        : (extension.toLowerCase() == '.gif' ? 'image/gif' : 'image/jpeg');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadAnnouncementImage({
    required XFile file,
    required String title,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = 'announcement_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'announcements/$fileName';
    final bucket = dotenv.get('SUPABASE_ANNOUNCEMENTS_BUCKET', fallback: 'announcement-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadEventImage({
    required XFile file,
    required String eventName,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = 'event_${eventName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'events/$fileName';
    final bucket = dotenv.get('SUPABASE_EVENT_BUCKET', fallback: dotenv.get('SUPABASE_EVENTS_BUCKET', fallback: 'event-pictures'));

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadPaymentReceipt({
    required XFile file,
    required String studentId,
    required String feeId,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = 'receipt_${studentId}_${feeId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'receipts/$fileName';
    final bucket = dotenv.get('SUPABASE_RECEIPTS_BUCKET', fallback: 'receipt-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadEventHighlight({
    required XFile file,
    required String eventId,
    required String userId,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = 'highlight_${eventId}_${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'highlights/$eventId/$fileName';
    final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<List<FileObject>> listFiles({
    required String bucket,
    String? folder,
  }) async {
    return await _client.storage.from(bucket).list(path: folder);
  }

  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadExcuseDocument({
    required XFile file,
    required String studentId,
    required String eventId,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = p.extension(file.name);
    final fileName = 'excuse_${studentId}_${eventId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'excuses/$fileName';
    final bucket = dotenv.get('SUPABASE_EXCUSE_BUCKET', fallback: 'excuse-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }
}

