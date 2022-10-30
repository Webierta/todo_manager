import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Column(
                    children: const [],
                  ),
                ),
                // Page Info
                //ListTile(),
                // const Divider(),
                // Page About
                //ListTile(),
                // const Divider(),
                // Page Support
                // ListTile(),
                // const Divider(),
                // Idioma
                // const Divider(),
                // Theme
              ],
            ),
          ),
          const Divider(),
          const Text('versión 1.0.0'),
        ],
      ),
    );
  }
}
