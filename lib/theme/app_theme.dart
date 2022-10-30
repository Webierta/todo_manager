import 'package:flutter/material.dart';

class AppTheme {
  AppTheme();

  static AppTheme? _current;

  static AppTheme get current {
    _current ??= AppTheme();
    return _current!;
  }

  static ThemeData? lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    primarySwatch: Colors.teal,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.teal[50],
    ),
    listTileTheme: ListTileThemeData(
      selectedTileColor: Colors.teal[50],
    ),
    expansionTileTheme: ExpansionTileThemeData(
      textColor: Colors.teal,
      backgroundColor: Colors.teal[50],
      collapsedBackgroundColor: Colors.transparent,
    ),
    chipTheme: const ChipThemeData(
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF212121),
      ),
    ),
    typography: Typography(
      white: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
        labelSmall: TextStyle(fontSize: 11),
      ),
    ),
  );
}
