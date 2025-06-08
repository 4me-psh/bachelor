import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF8D6E63), 
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD7CCC8), 
      primary: const Color(0xFF8D6E63), 
      secondary: const Color(0xFFBCAAA4), 
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8F0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 126, 92, 80),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Color(0xFFFFF8F0),
      selectedIconTheme: IconThemeData(color: Color(0xFF8D6E63)),
      selectedLabelTextStyle: TextStyle(color: Color(0xFF8D6E63)),
      unselectedIconTheme: IconThemeData(color: Colors.grey),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF8D6E63), width: 2),
      ),
      labelStyle: TextStyle(color: Color(0xFF8D6E63)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8D6E63),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark();
}
