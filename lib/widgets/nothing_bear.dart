import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NothingBear extends StatelessWidget {
  final bool isPageTask;
  const NothingBear({super.key, this.isPageTask = true});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;

    String imageName = 'assets/nothing.png';
    String text = appLang.nothingTodo;
    if (!isPageTask) {
      imageName = 'assets/nothing2.png';
      text = appLang.horaDeEmpezar;
    }

    return SizedBox.expand(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        widthFactor: 0.8,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                imageName,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
