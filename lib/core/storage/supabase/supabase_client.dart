import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientProvider {
  static const String supabaseUrl = 'https://slvfourmyqgkzjddyliv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNsdmZvdXJteXFna3pqZGR5bGl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5ODc5MjEsImV4cCI6MjA5NTU2MzkyMX0.H2f9ZMg3JjAT9L-ljWo0Mb9FXK04Hw51Hl3lJ7iI5XA';

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  static StreamSubscription<AuthState>? _authSubscription;

  static void onAuthChange(void Function(AuthChangeEvent) callback) {
    _authSubscription?.cancel();
    _authSubscription = client.auth.onAuthStateChange.listen((authState) {
      callback(authState.event);
    });
  }

  static void dispose() {
    _authSubscription?.cancel();
  }
}
