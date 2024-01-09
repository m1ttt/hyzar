import 'package:flutter/material.dart';

ThemeData buildThemeData(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    brightness: colorScheme.brightness,
    scaffoldBackgroundColor: colorScheme.background,
    typography: Typography.material2021(),
    useMaterial3: true,
  );
}
