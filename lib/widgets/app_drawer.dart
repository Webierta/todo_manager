import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../l10n/app_locale.dart';
import '../l10n/language_data.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Column(
                    children: const [],
                  ),
                ),
                // Page Info
                //ListTile(),
                // const Divider(),
                // Page About
                //ListTile(),
                // const Divider(),
                // Page Support
                // ListTile(),
                // const Divider(),
                // Idioma
                ListTile(
                  leading: const Icon(Icons.language),
                  minLeadingWidth: 20,
                  title: Text(appLang.idioma),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: context.watch<AppLocale>().locale.languageCode,
                      onChanged: (String? value) =>
                          context.read<AppLocale>().changeLocale(Locale(value!)),
                      /* items: ['en', 'es'].map((lang) {
                        String flag = lang == 'es' ? '🇪🇸' : '🇬🇧';
                        return DropdownMenuItem<String>(
                          value: lang,
                          child: Text(flag),
                        );
                      }).toList(), */
                      items: LanguageData.langs
                          .map((lang) => DropdownMenuItem<String>(
                                value: lang.languageCode,
                                child: Text('${lang.flag}  ${lang.name}'),
                              ))
                          .toList(),
                      focusColor: Colors.transparent,
                      underline: null,
                    ),
                  ),
                ),

                // const Divider(),
                // Theme
              ],
            ),
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              '${appLang.version} 1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
