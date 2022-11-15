import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppBrightness extends ChangeNotifier {
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  initBrightness() {
    bool? darkTheme = Hive.box('settings').get('darkTheme', defaultValue: false);
    _darkTheme = darkTheme ?? false;
    notifyListeners();
  }

  void setBrightness(bool value) {
    _darkTheme = value;
    Hive.box('settings').put('darkTheme', value);
    notifyListeners();
  }
}
