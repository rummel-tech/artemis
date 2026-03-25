import 'package:flutter/material.dart';

/// Rummel Tech design system theme implementation.
///
/// All color values are sourced from docs/architecture/DESIGN_SYSTEM.md.
/// Use [RummelTheme.lightTheme] and [RummelTheme.darkTheme] in MaterialApp.
class RummelTheme {
  // Primary — Rummel Blue
  static const Color primary500 = Color(0xFF1E88E5);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary600 = Color(0xFF1565C0);
  static const Color primary700 = Color(0xFF0D47A1);
  static const Color primary100 = Color(0xFFBBDEFB);

  // Secondary — Teal
  static const Color secondary500 = Color(0xFF26A69A);
  static const Color secondary400 = Color(0xFF4DB6AC);
  static const Color secondary600 = Color(0xFF00897B);
  static const Color secondary100 = Color(0xFFB2DFDB);

  // Semantic
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: primary500,
          onPrimary: Colors.white,
          primaryContainer: primary100,
          onPrimaryContainer: primary700,
          secondary: secondary500,
          onSecondary: Colors.white,
          secondaryContainer: secondary100,
          onSecondaryContainer: secondary600,
          error: errorColor,
          onError: Colors.white,
          surface: Color(0xFFFAFAFA),
          onSurface: Color(0xFF1C1B1F),
          onSurfaceVariant: Color(0xFF49454F),
          outline: Color(0xFF79747E),
        ),
        textTheme: _textTheme,
        cardTheme: const CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(64, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary500,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 80,
          indicatorColor: secondary100,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary400,
          onPrimary: Colors.white,
          primaryContainer: primary700,
          onPrimaryContainer: primary100,
          secondary: secondary400,
          onSecondary: Colors.white,
          secondaryContainer: secondary600,
          onSecondaryContainer: secondary100,
          error: Color(0xFFCF6679),
          onError: Colors.white,
          surface: Color(0xFF121212),
          onSurface: Color(0xFFE6E1E5),
          onSurfaceVariant: Color(0xFFCAC4D0),
          outline: Color(0xFF938F99),
        ),
        textTheme: _textTheme,
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(64, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          height: 80,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      );

  // Material 3 type scale per DESIGN_SYSTEM.md
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, height: 64 / 57),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, height: 52 / 45),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, height: 44 / 36),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, height: 40 / 32),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, height: 36 / 28),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, height: 32 / 24),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, height: 28 / 22),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 24 / 16),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 20 / 14),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 16 / 12),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 16 / 12),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 16 / 11),
  );
}
