import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/supabase/supabase_client.dart';
import 'app/app.dart';
import 'features/admin/admin_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await SupabaseClientProvider.initialize();
    runApp(const AdminApp());
  } else {
    runApp(const ProviderScope(child: BBVAFuerzaVentasApp()));
  }
}
