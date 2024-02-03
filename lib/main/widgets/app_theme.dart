import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildThemeData(ColorScheme colorScheme) {
  print(colorScheme);
  ColorScheme updatedColorScheme = colorScheme.copyWith(
      primary: const Color.fromARGB(255, 18, 136, 185),
      secondary: const Color.fromARGB(255, 31, 195, 146),
      surfaceTint: Color.fromARGB(255, 31, 195, 146),
      primaryContainer: Color.fromARGB(255, 31, 195, 146));
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
