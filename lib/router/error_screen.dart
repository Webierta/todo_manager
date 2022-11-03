import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'routes_const.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({Key? key, this.error = 'Error'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(appLang.pageNull)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => context.go(homePage),
              child: Text(appLang.home),
            ),
          ],
        ),
      ),
    );
  }
}
