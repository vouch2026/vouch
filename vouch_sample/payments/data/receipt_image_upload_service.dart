import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/services/supabase_storage_service.dart';

class ReceiptImageUploadService {
  ReceiptImageUploadService._();

  static Future<String> uploadReceiptImage({required File imageFile}) async {
    try {
      final bucketName = dotenv.env['SUPABASE_RECEIPTS_BUCKET'] ?? 'receipts';
      final String publicUrl = await SupabaseStorageService.instance.uploadFile(
        bucketName: bucketName,
        file: imageFile,
      );
      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload receipt image to Supabase Storage: $error');
    }
  }
}
