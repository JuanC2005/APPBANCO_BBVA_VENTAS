import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'router.dart';

class BBVAFuerzaVentasApp extends StatelessWidget {
  const BBVAFuerzaVentasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BBVA Fuerza de Ventas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: BBVAColors.primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: BBVAColors.primaryBlue,
          primary: BBVAColors.primaryBlue,
          secondary: BBVAColors.accentBlue,
        ),
        scaffoldBackgroundColor: BBVAColors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: BBVAColors.primaryBlue,
          foregroundColor: BBVAColors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BBVAColors.primaryBlue,
            foregroundColor: BBVAColors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: BBVAColors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: BBVAColors.primaryBlue),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
