import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'l10n/app_locale.dart';
import 'models/item.dart';
import 'models/tag.dart';
import 'models/todo.dart';
import 'models/todo_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await getApplicationDocumentsDirectory();
  Hive
    ..init(directory.path)
    ..registerAdapter(TodoAdapter())
    ..registerAdapter(ItemAdapter())
    ..registerAdapter(TagAdapter());
  await Hive.openBox<Todo>('todos');
  await Hive.openBox<String>('localeBox');
  //await Hive.deleteFromDisk();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => AppLocale()),
      ],
      child: const ToDoManager(),
    ),
  );
}

class ToDoManager extends StatefulWidget {
  const ToDoManager({super.key});
  @override
  State<ToDoManager> createState() => _ToDoManagerState();
}

class _ToDoManagerState extends State<ToDoManager> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AppLocale>(context, listen: false).initLocale();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'To-Do Manager',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: context.watch<AppLocale>().locale,
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter().router,
    );
  }
}
