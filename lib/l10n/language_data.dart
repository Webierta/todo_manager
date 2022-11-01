class LanguageData {
  final String _flag;
  final String _name;
  final String _languageCode;

  LanguageData(this._flag, this._name, this._languageCode);

  String get flag => _flag;
  String get name => _name;
  String get languageCode => _languageCode;

  static String _countryCodeToFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
        );
  }

  static List<LanguageData> _languageList() {
    return <LanguageData>[
      LanguageData(_countryCodeToFlag('gb'), 'English', 'en'),
      LanguageData(_countryCodeToFlag('es'), 'Español', 'es'),
      //LanguageData(_countryCodeToFlag('de'), 'Deutsche', 'de'),
    ];
  }

  static List<LanguageData> get langs => LanguageData._languageList();

  static List<String> supportedLocales = langs.map((lang) => lang.languageCode).toList();

  //static Iterable<Locale> iterableLocales = langs.map((lang) => Locale(lang.languageCode));

}
