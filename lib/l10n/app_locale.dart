import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppLocale extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  initLocale() {
    String? languageCode = Hive.box('settings').get('languageCode', defaultValue: 'en');
    _locale = Locale(languageCode ?? 'en');
    notifyListeners();
  }

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    Hive.box('settings').put('languageCode', newLocale.languageCode);
    notifyListeners();
  }
}
