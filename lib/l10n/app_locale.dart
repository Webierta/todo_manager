import 'package:flutter/material.dart';

class AppLocale extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}
