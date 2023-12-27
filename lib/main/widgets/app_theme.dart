// app_theme.dart
import 'package:flutter/material.dart';

ThemeData buildThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, // Cambia a tu color principal deseado aquí
    ).copyWith(
      secondary: Colors.blue, // Cambia a tu color secundario deseado aquí
      surface: Colors.white, // Cambia el color de la superficie aquí
      background: Colors.white, // Cambia el color de fondo aquí
    ),
    brightness: Brightness.light, // Set light theme
    scaffoldBackgroundColor: Colors.white, // Set background color to white
    typography: Typography.material2021(), // Set typography
    useMaterial3: true,
  );
}
