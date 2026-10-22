import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static String get url => dotenv.env['SUPABASE_URL']?.trim() ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  static bool get hasValidCredentials {
    return url.isNotEmpty &&
        url.startsWith('https://') &&
        !url.contains('your_project_url') &&
        anonKey.isNotEmpty &&
        !anonKey.contains('your_anon_key');
  }

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> initialize() async {
    if (!hasValidCredentials) {
      debugPrint('[SupabaseConfig] Valid Supabase credentials not found in .env. Running in Demo/Local mode.');
      _isInitialized = false;
      return false;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseConfig] Supabase successfully initialized with URL: $url');
      return true;
    } catch (e) {
      debugPrint('[SupabaseConfig] Failed to initialize Supabase: $e');
      _isInitialized = false;
      return false;
    }
  }
}
