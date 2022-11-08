import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/todo.dart';
import '../pages/about_page.dart';
import '../pages/home.dart';
import '../pages/info_page.dart';
import '../pages/support_page.dart';
import '../pages/todo_page.dart';
import 'error_screen.dart';
import 'routes_const.dart';

class AppRouter {
  static get router => _router;

  static final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: homePage,
        builder: (BuildContext context, GoRouterState state) {
          return const Home();
        },
      ),
      GoRoute(
        path: todoPage,
        builder: (BuildContext context, GoRouterState state) {
          return TodoPage(todo: state.extra as Todo);
        },
      ),
      GoRoute(
        path: infoPage,
        builder: (BuildContext context, GoRouterState state) {
          return const InfoPage();
        },
      ),
      GoRoute(
        path: aboutPage,
        builder: (BuildContext context, GoRouterState state) {
          return const AboutPage();
        },
      ),
      GoRoute(
        path: supportPage,
        builder: (BuildContext context, GoRouterState state) {
          return const SupportPage();
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),
  );
}
