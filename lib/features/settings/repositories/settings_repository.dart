import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';

class SettingsRepository {
  final SupabaseClient _client;
  final SettingsService _service;

  SettingsRepository(this._client, this._service);

  Future<bool> _isOnline() async {
    if (kIsWeb) return true;
    try {
      final host = Uri.parse(_client.rest.url).host;
      final result = await InternetAddress.lookup(host).timeout(const Duration(milliseconds: 800));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String? _getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }

  AppSettings getSettings() {
    return _service.getSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _service.saveSettings(settings);

    final userId = _getCurrentUserId();
    if (userId == null) return;

    final isOnline = await _isOnline();
    if (!isOnline) return;

    try {
      final jsonMap = settings.toJson();
      jsonMap['user_id'] = userId;
      jsonMap['updated_at'] = DateTime.now().toUtc().toIso8601String();
      
      await _client.from('user_settings').upsert(jsonMap);
    } catch (e) {
      debugPrint('Failed to sync settings with Supabase: $e');
    }
  }

  Future<void> syncSettings() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    final isOnline = await _isOnline();
    if (!isOnline) return;

    try {
      final response = await _client
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        final Map<String, dynamic> remoteJson = Map<String, dynamic>.from(response);
        remoteJson.remove('user_id');
        remoteJson.remove('updated_at');
        
        final remoteSettings = AppSettings.fromJson(remoteJson);
        await _service.saveSettings(remoteSettings);
      } else {
        // Create settings on remote with local settings if they don't exist yet
        final localSettings = _service.getSettings();
        await saveSettings(localSettings);
      }
    } catch (e) {
      debugPrint('Failed to sync settings from Supabase: $e');
    }
  }
}
