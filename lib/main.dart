import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'navigation/routes.dart';
import 'services/supabase_config.dart';
import 'repository/auth_repository.dart';
import 'repository/cartera_repository.dart';
import 'viewmodel/auth_oficial_viewmodel.dart';
import 'viewmodel/cartera_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  final supabase = SupabaseConfig.client;
  final authRepository = AuthRepository(supabase);
  final carteraRepository = CarteraRepository(supabase);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthOficialViewModel(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CarteraViewModel(carteraRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BBVA Fuerza de Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      routerConfig: router,
    );
  }
}
