import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Query db metadata', () async {
    SharedPreferences.setMockInitialValues({});

    final envFile = File('.env');
    final lines = envFile.readAsLinesSync();
    String? url;
    String? anonKey;
    for (var line in lines) {
      if (line.startsWith('SUPABASE_URL=')) {
        url = line.split('SUPABASE_URL=')[1].trim();
      }
      if (line.startsWith('SUPABASE_ANON_KEY=')) {
        anonKey = line.split('SUPABASE_ANON_KEY=')[1].trim();
      }
    }

    expect(url, isNotNull);
    expect(anonKey, isNotNull);

    await Supabase.initialize(url: url!, anonKey: anonKey!);
    final client = Supabase.instance.client;

    try {
      final res = await client
          .from('organizations')
          .select('*')
          .limit(1);
      print('SUCCESS! Organizations table queried: $res');
    } catch (e) {
      print('ERROR querying organizations: $e');
    }

    try {
      final res = await client
          .from('organization_settings')
          .select('*')
          .limit(1);
      print('SUCCESS! Organization_settings table queried: $res');
    } catch (e) {
      print('ERROR querying organization_settings: $e');
    }
  });
}
