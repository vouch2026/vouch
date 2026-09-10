import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Could not load .env asset, using fallback env: $e');
    }
    
    final url = dotenv.maybeGet('SUPABASE_URL') ?? 
                const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? 
                    const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
