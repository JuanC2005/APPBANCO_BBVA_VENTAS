import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/supabase/supabase_client.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseClientProvider.initialize();
  runApp(const ProviderScope(child: BBVAFuerzaVentasApp()));
}
