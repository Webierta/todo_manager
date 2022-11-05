import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/app_locale.dart';
import '../l10n/language_data.dart';
import '../router/routes_const.dart';

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
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(appLang.idioma),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: context.watch<AppLocale>().locale.languageCode,
                      onChanged: (String? value) {
                        context.read<AppLocale>().changeLocale(Locale(value!));
                      },
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(appLang.home),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(homePage);
                  }),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(appLang.info),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(infoPage);
                  }),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(appLang.about),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(aboutPage);
                  }),
                ),
                ListTile(
                  leading: const Icon(Icons.local_cafe_outlined),
                  title: Text(appLang.support),
                  onTap: (() {
                    Navigator.of(context).pop();
                  }),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: Text(appLang.exit),
                  onTap: () async {
                    Navigator.of(context).pop();
                    SystemNavigator.pop();
                  },
                ),
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
