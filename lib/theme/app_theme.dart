import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:todo_manager/theme/app_color.dart';

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
    primaryColor: AppColor.primaryColor,
    primarySwatch: AppColor.primarySwatch,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColor.primary50,
    ),
    listTileTheme: const ListTileThemeData(
      selectedTileColor: AppColor.primary50,
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      textColor: AppColor.primaryColor,
      backgroundColor: AppColor.primary50,
      collapsedBackgroundColor: Colors.transparent,
    ),
    chipTheme: const ChipThemeData(
      labelStyle: TextStyle(
        fontFeatures: [FontFeature.tabularFigures()],
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF212121),
      ),
    ),
    typography: Typography(
      white: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
      ),
    ),
  );
}
