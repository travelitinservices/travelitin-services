import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E3C72);
  static const Color accentColor = Color(0xFF2A5298);
  static const Color backgroundColor = Color(0xFFF3F5F7);

  static BoxDecoration get glassmorphismDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      );

  static InputDecoration get inputDecoration => InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
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
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  static CardTheme get cardTheme => CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      );

  static TextStyle bodyTextStyle(bool isSmallScreen) => TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        color: Colors.black87,
        height: 1.5,
      );

  static ThemeData get lightTheme => ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: accentColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardTheme: cardTheme,
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
            borderSide: const BorderSide(color: accentColor, width: 2),
          ),
        ),
      );
} 