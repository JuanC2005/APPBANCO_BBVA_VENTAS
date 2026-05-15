import 'package:flutter/material.dart';
import 'colors.dart';

class BBVATypography {
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: BBVAColors.black, // Letras NEGRAS
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BBVAColors.black, // Letras NEGRAS
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    color: BBVAColors.black, // Letras NEGRAS
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 14,
    color: BBVAColors.black, // Letras NEGRAS
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: BBVAColors.white, // Letras BLANCAS (para botones azules)
  );
}
