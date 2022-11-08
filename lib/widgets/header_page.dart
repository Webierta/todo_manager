import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HeaderPage extends StatelessWidget {
  const HeaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Column(
      children: [
        Text(
          'TO-DO MANAGER',
          style: Theme.of(context).typography.white.headlineSmall,
        ),
        Image.asset('assets/ic_launcher.png'),
        Text('${appLang.version} 1.0.0', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 10),
      ],
    );
  }
}
