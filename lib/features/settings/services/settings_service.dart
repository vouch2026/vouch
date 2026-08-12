import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings_model.dart';

class SettingsService {
  final Box _box;

  SettingsService(this._box);

  static const String _settingsKey = 'app_settings_data';

  AppSettings getSettings() {
    final rawData = _box.get(_settingsKey);
    if (rawData == null) {
      return const AppSettings();
    }
    
    try {
      final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawData as Map);
      return AppSettings.fromJson(jsonMap);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_settingsKey, settings.toJson());
  }
}
