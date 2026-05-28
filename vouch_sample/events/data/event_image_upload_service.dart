import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/supabase_storage_service.dart';

class EventImageUploadService {
  EventImageUploadService._();

  static Future<String> uploadEventImage({required File imageFile}) async {
    try {
      final bucketName = dotenv.env['SUPABASE_EVENTS_BUCKET'] ?? 'events';
      final String publicUrl = await SupabaseStorageService.instance.uploadFile(
        bucketName: bucketName,
        file: imageFile,
      );
      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload event image to Supabase Storage: $error');
    }
  }
}
