import "package:flutter/material.dart";

/// Uniroid's look: white-forward (her favourite), soft pink accents,
/// and a matching dark mode.
class UniroidTheme {
  UniroidTheme._();

  static const pink = Color(0xFFE91E63);
  static const pinkDeep = Color(0xFFAD1457);
  static const pinkSoft = Color(0xFFF8BBD0);
  static const blush = Color(0xFFFFF7FA);

  static const darkBg = Color(0xFF241A20);
  static const darkCard = Color(0xFF2E2129);

  static ThemeData light() => _base(
    brightness: Brightness.light,
    scaffold: blush,
    card: Colors.white,
    ink: const Color(0xFF3A2A33),
    muted: const Color(0xFF8A7480),
    line: const Color(0xFFF3D7E3),
  );

  static ThemeData dark() => _base(
    brightness: Brightness.dark,
    scaffold: darkBg,
    card: darkCard,
    ink: const Color(0xFFF7EAF0),
    muted: const Color(0xFFC3A7B5),
    line: const Color(0xFF4A3340),
  );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffold,
    required Color card,
    required Color ink,
    required Color muted,
    required Color line,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: pink,
      brightness: brightness,
      surface: card,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(surface: card, onSurface: ink),
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: line),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: ink),
        bodySmall: TextStyle(color: muted),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: pink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: pink, width: 2),
        ),
      ),
    );
  }
}
