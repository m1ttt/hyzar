import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyzar/utilidades/Colores.dart';

ThemeData buildThemeData(ColorScheme colorScheme) {
  print(colorScheme);
  ColorScheme updatedColorScheme = colorScheme.copyWith(
      primary: Colores.verde,
      secondary: Colores.azul,
      surfaceTint: Colores.verde,
      primaryContainer: Colores.verde);
  return ThemeData(
    colorScheme: updatedColorScheme,
    brightness: updatedColorScheme.brightness,
    scaffoldBackgroundColor: updatedColorScheme.background,
    textTheme: GoogleFonts.outfitTextTheme(
      Typography.material2021().black,
    ).apply(
      bodyColor: updatedColorScheme.onBackground,
      displayColor: updatedColorScheme.onBackground,
    ),
    useMaterial3: true,
  );
}
