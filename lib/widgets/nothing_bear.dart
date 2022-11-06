import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NothingBear extends StatelessWidget {
  final bool isPageTask;
  const NothingBear({super.key, this.isPageTask = true});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;

    String imageName = 'assets/nothing_bear.png';
    String text = appLang.nothingTodo;
    if (!isPageTask) {
      imageName = 'assets/empty_items.png';
      text = appLang.horaDeEmpezar;
    }

    /* return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
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
      ),
    ); */
    return SizedBox.expand(
      child: FractionallySizedBox(
        heightFactor: 0.8,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                //'assets/nothing_bear.png',
                imageName,
                fit: BoxFit.contain,
                color: Colors.white.withOpacity(0.7),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
