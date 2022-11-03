import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../widgets/app_drawer.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(appLang.info)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Markdown(data: appLang.mdInfo),
      ),
    );
  }
}
