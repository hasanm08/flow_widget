import 'package:flutter/material.dart';

/// Light / dark themes for the example app.
abstract final class AppTheme {
  static const _seed = Color(0xFF0B6E4F);

  /// Light theme.
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  /// Dark theme.
  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
