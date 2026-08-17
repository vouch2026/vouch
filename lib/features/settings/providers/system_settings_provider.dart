import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/supabase_config.dart';

class SystemSettingsNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      final response = await SupabaseConfig.client
          .from('system_settings')
          .select('value')
          .eq('key', 'auto_activate_registrations')
          .maybeSingle();

      if (response != null && response['value'] != null) {
        final valueMap = response['value'] as Map<String, dynamic>;
        return valueMap['enabled'] as bool? ?? false;
      }
    } catch (e) {
      // In case the table is not migrated yet or errors occur, default to false
      return false;
    }
    return false;
  }

  Future<void> toggleAutoActivation(bool enabled) async {
    state = const AsyncLoading();
    try {
      await SupabaseConfig.client
          .from('system_settings')
          .upsert({
            'key': 'auto_activate_registrations',
            'value': {'enabled': enabled},
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
      state = AsyncData(enabled);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final systemSettingsProvider = AsyncNotifierProvider<SystemSettingsNotifier, bool>(() {
  return SystemSettingsNotifier();
});
