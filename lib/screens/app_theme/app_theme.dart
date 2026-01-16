
import 'package:flutter/material.dart';

class AppTheme{
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      background: Colors.grey.shade100,
      error: Colors.red
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none
      ),
    ),

    iconTheme: IconThemeData(color: Colors.black87)
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Color(0xFF121212),

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Colors.redAccent,
    ),

    cardTheme: CardThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 2,
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    iconTheme: IconThemeData(color: Colors.white),
  );
}