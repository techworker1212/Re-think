import 'package:flutter/material.dart';

const rethinkTeal = Color(0xFF0F766E);

ThemeData rethinkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: rethinkTeal,
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
