import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../widgets/app_drawer.dart';
import '../widgets/header_page.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(appLang.info)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const HeaderPage(),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.mdInfo),
        ],
      ),
    );
  }
}
