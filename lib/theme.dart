import 'package:flutter/material.dart';

const recenterTeal = Color(0xFF0F766E);

ThemeData recenterTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: recenterTeal,
    brightness: Brightness.light,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
  );
}
