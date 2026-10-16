import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  /// Normalizes the Supabase base URL.
  ///
  /// `supabase_flutter` concatenates `'$url/auth/v1'` verbatim, so a
  /// trailing slash in `SUPABASE_URL` produces `//auth/v1` which self-hosted
  /// Kong/GoTrue rejects. Stripping trailing slashes fixes that for
  /// auth/rest/storage/realtime/functions at once.
  static String normalizeUrl(String raw) {
    return raw.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Could not load .env asset, using fallback env: $e');
    }

    final rawUrl = (dotenv.maybeGet('SUPABASE_URL') ??
            const String.fromEnvironment('SUPABASE_URL', defaultValue: ''))
        .trim();
    final anonKey = (dotenv.maybeGet('SUPABASE_ANON_KEY') ??
            const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''))
        .trim();

    if (rawUrl.isEmpty) {
      throw StateError(
        'SUPABASE_URL is empty. Set it via .env or '
        '--dart-define=SUPABASE_URL=https://supabase.vouchedu.app (no trailing slash).',
      );
    }
    if (anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY is empty. Set it via .env or '
        '--dart-define=SUPABASE_ANON_KEY=... .',
      );
    }

    final url = normalizeUrl(rawUrl);
    if (rawUrl != url) {
      debugPrint('Supabase URL had trailing slash, normalized.');
    }

    Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (e) {
      throw StateError('SUPABASE_URL is not a valid URI ("$url"): $e');
    }
    if (!uri.hasScheme || uri.host.isEmpty) {
      throw StateError(
        'SUPABASE_URL must include scheme and host, got "$url". '
        'Expected e.g. https://supabase.vouchedu.app (no trailing slash).',
      );
    }
    // Never log the anon key. Host-only logging is safe.
    debugPrint('Supabase init host: ${uri.host}');

    if (kIsWeb && kReleaseMode && !url.startsWith('https://')) {
      throw StateError(
        'Insecure SUPABASE_URL for web release: "$url". '
        'Browsers block https://vouchedu.app -> http://... as mixed-content, '
        'surfacing as AuthRetryableFetchException/NetworkError on '
        '/auth/v1/token. Use https://supabase.vouchedu.app (no trailing slash).',
      );
    }
    if (kIsWeb && url.startsWith('http://')) {
      debugPrint(
        'WARNING: SUPABASE_URL uses http:// on web (${uri.host}). '
        'Use https:// in production to avoid mixed-content blocking.',
      );
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
