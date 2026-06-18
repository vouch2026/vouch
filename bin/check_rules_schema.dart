import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Let's parse the supabase url and anon key from the .env file
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('No .env file found');
    exit(1);
  }

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

  if (url == null || anonKey == null) {
    print('Failed to parse Supabase credentials from .env');
    exit(1);
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
  final client = Supabase.instance.client;

  try {
    final res = await client.from('sanction_rules').select().limit(1);
    print('SUCCESS: ${res}');
    if (res.isNotEmpty) {
      print('Columns: ${res.first.keys.toList()}');
    } else {
      print('Table is empty, trying to fetch table info via RPC or fallback');
      // Try to insert a dummy rule and rollback/delete, or just fetch using general select *
      final testRes = await client.from('sanction_rules').select();
      if (testRes.isNotEmpty) {
        print('Columns from all rows: ${testRes.first.keys.toList()}');
      } else {
        print('No rows. We will check migration.sql structure.');
      }
    }
  } catch (e) {
    print('ERROR: $e');
  }

  exit(0);
}
