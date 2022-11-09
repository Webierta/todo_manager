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
          MarkdownBody(data: appLang.info1),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info2),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info3),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info4),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info5),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info6),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info7),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info8),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.info9),
        ],
      ),
    );
  }
}
