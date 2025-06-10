import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF90CAF9); // Lighter blue
  static const Color accentLight = Color(0xFF42A5F5);
  static const Color backgroundLight = Color(0xFFF5FAFF);
  static const Color textLight = Color(0xFF222B45);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF0D253F);
  static const Color accentDark = Color(0xFF1976D2);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textDark = Color(0xFFF5FAFF);

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryLight,
        scaffoldBackgroundColor: backgroundLight,
        colorScheme: ColorScheme.light(
          primary: primaryLight,
          secondary: accentLight,
          background: backgroundLight,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentLight, width: 2),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textLight),
          bodyMedium: TextStyle(color: textLight),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryDark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: ColorScheme.dark(
          primary: primaryDark,
          secondary: accentDark,
          background: backgroundDark,
        ),
        cardTheme: CardTheme(
          color: Color(0xFF1E293B),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentDark, width: 2),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textDark),
          bodyMedium: TextStyle(color: textDark),
        ),
      );

  static final InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final CardTheme cardTheme = CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.all(8),
  );

  static final BoxDecoration glassmorphismDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(35),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        spreadRadius: 2,
      ),
    ],
  );

  static TextStyle errorTextStyle(bool isSmallScreen) {
    return TextStyle(
      color: Colors.red,
      fontSize: isSmallScreen ? 12 : 14,
      fontWeight: FontWeight.w500,
    );
  }
}