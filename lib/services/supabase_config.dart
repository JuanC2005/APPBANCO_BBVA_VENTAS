import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String anonKey = 'tu-anon-key';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
