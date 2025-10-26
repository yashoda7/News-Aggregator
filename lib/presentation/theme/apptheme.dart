import 'package:flutter/material.dart';

class AppTheme {
   ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    // scaffoldBackgroundColor: const Color.fromARGB(255, 100, 255, 154),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 58, 129, 160),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
   
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
    ),

  );

   ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.orange,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 50, 6, 6),
      elevation: 0,
    ),
   
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
   
  );
}