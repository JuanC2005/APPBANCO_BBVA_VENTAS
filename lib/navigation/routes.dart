import 'package:go_router/go_router.dart';
import '../view/auth/login_oficial_screen.dart';
import '../view/home/cartera_diaria_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginOficialScreen()),
    GoRoute(
      path: '/cartera',
      builder: (context, state) => const CarteraDiariaScreen(),
    ),
  ],
);
