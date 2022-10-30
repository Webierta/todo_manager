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
    //scaffoldBackgroundColor: AppColors.screenBackground,
    primaryColor: Colors.teal,
    //colorScheme: const ColorScheme.light(secondary: Colors.white),
    //dividerColor: Colors.transparent,
    //expansionTileTheme: ExpansionTileThemeData(),
    //cardColor: Colors.white,
    /* floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.blue,
    ), */
  );
}
