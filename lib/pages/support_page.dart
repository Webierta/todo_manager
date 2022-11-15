import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_drawer.dart';
import '../widgets/header_page.dart';

const String btcAddress = '15ZpNzqbYFx9P7wg4U438JMwZr2q3W6fkS';
const String urlPayPal = 'https://www.paypal.com/donate?hosted_button_id=986PSAHLH6N4L';
const String urlGitHub = 'https://github.com/Webierta/todo_manager/issues';

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;

    Future<void> launchweb(url) async {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    }

    clipboard(BuildContext context) {
      Clipboard.setData(const ClipboardData(text: btcAddress));
      var snackBar = SnackBar(content: Text(appLang.copiedClipboard));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(appLang.support)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          const HeaderPage(),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.support1),
          const SizedBox(height: 10.0),
          MarkdownBody(
            onTapLink: (text, href, title) => launchweb(href),
            data: appLang.support2,
          ),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.support3),
          const SizedBox(height: 10.0),
          MarkdownBody(data: appLang.support4),
          const SizedBox(height: 10.0),
          Image.asset('assets/Bitcoin_QR.png', height: 150),
          const SizedBox(height: 20.0),
          MarkdownBody(data: appLang.support5),
          const SizedBox(height: 10.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(color: Colors.black12, style: BorderStyle.solid),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  border: Border.all(color: const Color(0xFFFFFFFF), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      padding: const EdgeInsets.all(8.0),
                      decoration: const ShapeDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.zero,
                            topRight: Radius.zero,
                          ),
                          side: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          btcAddress,
                          style: TextStyle(color: Color(0xFF455A64)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => clipboard(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          MarkdownBody(data: appLang.support6),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Color(0xFFE0F2F1)),
                ),
                onPressed: () => launchweb(urlPayPal),
                child: Image.asset('assets/paypal_logo.png', width: 100),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
