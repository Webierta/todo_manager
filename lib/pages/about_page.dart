import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router/routes_const.dart';
import '../widgets/app_drawer.dart';
import '../widgets/header_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;

    Future<void> launchweb(url) async {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(appLang.about)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const HeaderPage(),
          const SizedBox(height: 10.0),
          MarkdownBody(
            data: appLang.about1,
            styleSheet: MarkdownStyleSheet(
              blockquoteDecoration: const BoxDecoration(color: Colors.teal),
              p: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.about2),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.about3),
          const SizedBox(height: 10.0),
          MarkdownBody(
            onTapLink: (text, href, title) => launchweb(href),
            data: appLang.about4,
          ),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.about5),
          const SizedBox(height: 10.0),
          MarkdownBody(
            onTapLink: (text, href, title) => context.go(supportPage),
            data: appLang.about6,
          ),
          const Divider(height: 40),
          MarkdownBody(data: appLang.about7),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.about8),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.about9),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.about10),
          const Divider(height: 40),
          MarkdownBody(data: appLang.about11),
          const SizedBox(height: 10.0),
          MarkdownBody(
            onTapLink: (text, href, title) => launchweb(href),
            data:
                '* Icon: [Webalys](https://icon-icons.com/users/tEC2Jcsb47Ns1yxQJFdn1/icon-sets/) '
                'in Icon-Icons (Free for commercial use).',
          ),
          MarkdownBody(
            onTapLink: (text, href, title) => launchweb(href),
            data: '* Background images: '
                '[MJ Jin](https://pixabay.com/es/users/la_petite_femme-2212305/) '
                'on Pixabay (Pixabay License: Free for commercial use).',
          ),
          MarkdownBody(
            onTapLink: (text, href, title) => launchweb(href),
            data: '* Drawer Image: Image by '
                '[rawpixel](https://www.freepik.com/author/rawpixel-com) on Freepik (Free license).',
          ),
          MarkdownBody(
            onTapLink: (text, href, title) => launchweb(href),
            data: '* Check in foursquare icon by Pixel Buddha - '
                '[Flaticon](https://www.flaticon.es/autores/pixel-buddha) (Free for personal or '
                'commercial use with attribution).',
          ),
        ],
      ),
    );
  }
}
