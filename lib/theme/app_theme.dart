import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF90A53E); // Lime Green
  static const Color secondaryColor = Color(0xFF4F7035); // Olive Green
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF252525);
  static const Color darkSurface = Color(0xFF2F2F2F);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFA0A0A0);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F7F3);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF252525);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    Color bg = isDark ? darkBackground : lightBackground;
    Color surface = isDark ? darkSurface : lightSurface;
    Color textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    Color textSecondary = isDark ? darkTextSecondary : lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -1),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
