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

  static ThemeData? darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColor.primaryColor,
    primarySwatch: AppColor.primarySwatch,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColor.primary50,
    ),
    listTileTheme: const ListTileThemeData(
      selectedTileColor: AppColor.primary50,
    ),
    chipTheme: const ChipThemeData(
      padding: EdgeInsets.symmetric(horizontal: 4),
      //backgroundColor: Colors.black12,
      labelStyle: TextStyle(
        fontFeatures: [FontFeature.tabularFigures()],
        fontSize: 12,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      side: BorderSide(width: 0.5, color: Colors.white70),
    ),
    typography: Typography(
      white: const TextTheme(
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
      ),
    ),
  );

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
    chipTheme: const ChipThemeData(
      padding: EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: Colors.white54,
      labelStyle: TextStyle(
        fontFeatures: [FontFeature.tabularFigures()],
        fontSize: 12,
        color: Color(0xFF212121),
      ),
      iconTheme: IconThemeData(color: Colors.black87, size: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      side: BorderSide(width: 0.5, color: Colors.grey),
    ),
    typography: Typography(
      white: const TextTheme(
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
      ),
    ),
  );
}
