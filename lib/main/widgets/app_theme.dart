import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildThemeData(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    brightness: colorScheme.brightness,
    scaffoldBackgroundColor: colorScheme.background,
    textTheme: GoogleFonts.outfitTextTheme(
      Typography.material2021().black,
    ).apply(
      bodyColor: colorScheme.onBackground,
      displayColor: colorScheme.onBackground,
    ),
    useMaterial3: true,
  );
}
