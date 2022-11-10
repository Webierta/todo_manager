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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/esmeralda.jpg'),
                    ),
                    //color: AppColor.primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'TO-DO MANAGER',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w100,
                                ),
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            'EFFICIENTLY SIMPLE AND MINIMALISTIC',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: const Color(0xFFFFFFFF)),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Copyleft 2022',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                      Text(
                        'Jesús Cuerda (Webierta)',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                      Text(
                        'All Wrongs Reserved. Licencia GPLv3',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: const Color(0xFFFFFFFF)),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.home),
                  title: Text(appLang.home),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(homePage);
                  }),
                ),
                const Divider(),
                ListTile(
                  horizontalTitleGap: 0,
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
                                child: Text('${lang.flag}  ${lang.languageCode}'),
                                // ${lang.name.substring(0, 2)}
                              ))
                          .toList(),
                      focusColor: Colors.transparent,
                      underline: null,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.info_outline),
                  title: Text(appLang.info),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(infoPage);
                  }),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.code),
                  title: Text(appLang.about),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(aboutPage);
                  }),
                ),
                ListTile(
                  horizontalTitleGap: 0,
                  leading: const Icon(Icons.local_cafe_outlined),
                  title: Text(appLang.support),
                  onTap: (() {
                    Navigator.of(context).pop();
                    context.go(supportPage);
                  }),
                ),
                const Divider(),
                ListTile(
                  horizontalTitleGap: 0,
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
