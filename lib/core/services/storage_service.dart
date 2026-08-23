import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'image_compression_service.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService(this._client);

  Future<String> uploadProfilePhoto({
    required String identifier,
    required XFile file,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: ImageTransactionType.profile,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = 'avatar_${identifier.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'avatars/$fileName';
    final bucket = dotenv.get('SUPABASE_ORG_BUCKET', fallback: 'org-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadOrganizationAsset({
    required String code,
    required XFile file,
    required bool isLogo,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: isLogo ? ImageTransactionType.logo : ImageTransactionType.banner,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = '${isLogo ? 'logo' : 'banner'}_${code}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'organizations/$fileName';
    final bucket = dotenv.get('SUPABASE_ORG_BUCKET', fallback: 'org-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadAcademicAsset({
    required String code,
    required XFile file,
    required String type,
    bool isBanner = false,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: isBanner ? ImageTransactionType.banner : ImageTransactionType.logo,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final assetType = isBanner ? 'banner' : 'logo';
    final fileName = '${type}_${assetType}_${code.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'academic/$fileName';
    final bucket = dotenv.get('SUPABASE_ORG_BUCKET', fallback: 'org-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadAnnouncementImage({
    required XFile file,
    required String title,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: ImageTransactionType.announcement,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = 'announcement_${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'announcements/$fileName';
    final bucket = dotenv.get('SUPABASE_ANNOUNCEMENTS_BUCKET', fallback: 'announcement-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadEventImage({
    required XFile file,
    required String eventName,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: ImageTransactionType.event,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = 'event_${eventName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'events/$fileName';
    final bucket = dotenv.get('SUPABASE_EVENT_BUCKET', fallback: dotenv.get('SUPABASE_EVENTS_BUCKET', fallback: 'event-pictures'));

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadPaymentReceipt({
    required XFile file,
    required String studentId,
    required String feeId,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: ImageTransactionType.receipt,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = 'receipt_${studentId}_${feeId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'receipts/$fileName';
    final bucket = dotenv.get('SUPABASE_RECEIPTS_BUCKET', fallback: 'receipt-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<String> uploadEventHighlight({
    required XFile file,
    required String eventId,
    required String userId,
  }) async {
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: ImageTransactionType.highlight,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = 'highlight_${eventId}_${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'highlights/$eventId/$fileName';
    final bucket = dotenv.get('SUPABASE_HIGHLIGHTS_BUCKET', fallback: 'highlight-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
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
    final originalBytes = await file.readAsBytes();
    final compressedBytes = await ImageCompressionService.compressImage(
      bytes: originalBytes,
      type: ImageTransactionType.excuse,
    );
    final bytes = compressedBytes ?? originalBytes;
    final extension = compressedBytes != null ? '.webp' : p.extension(file.name);
    final fileName = 'excuse_${studentId}_${eventId}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final path = 'excuses/$fileName';
    final bucket = dotenv.get('SUPABASE_EXCUSE_BUCKET', fallback: 'excuse-pictures');

    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: compressedBytes != null ? 'image/webp' : null,
          ),
        );

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    await _client.storage.from(bucket).remove(paths);
  }

  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    return await _client.storage.from(bucket).download(path);
  }
}
