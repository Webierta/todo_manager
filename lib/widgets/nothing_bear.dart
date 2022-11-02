import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NothingBear extends StatelessWidget {
  const NothingBear({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/nothing_bear.png'),
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.7),
            BlendMode.modulate,
          ),
        ),
      ),
      child: Center(
        child: Text(
          appLang.nothingTodo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal),
        ),
      ),
    );
  }
}
