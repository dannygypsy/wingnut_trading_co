import 'package:flutter/material.dart';

class WingnutTheme {
  // Brand colors — derived from the Wingnut Sales app icon gradient
  static const Color teal = Color(0xFF0DB87A);        // primary action (deep emerald from icon bottom)
  static const Color tealDark = Color(0xFF098A5C);    // pressed / dark variant
  static const Color tealLight = Color(0xFFD0FBF0);   // tinted backgrounds, chips
  static const Color tealMid = Color(0xFF1FB896);     // accents, focus rings (icon midpoint)
  static const Color aqua = Color(0xFF62F6EA);        // highlight / icon top gradient

  static const Color background = Color(0xFFE8F5F0);  // very light teal tint (replaces grey)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0D2B22);  // deep teal-black
  static const Color textSecondary = Color(0xFF4B7B6A);
  static const Color border = Color(0xFFB2DDD0);
  static const Color danger = Color(0xFFDC2626);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: teal,
      primary: teal,
      onPrimary: Colors.white,
      surface: surface,
      background: background,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: teal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: teal,
        minimumSize: const Size(double.infinity, 56),
        side: const BorderSide(color: teal, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: teal, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}