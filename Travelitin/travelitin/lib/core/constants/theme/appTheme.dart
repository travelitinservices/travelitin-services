import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;

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