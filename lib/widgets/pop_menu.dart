import 'package:flutter/material.dart';

import '../models/menus.dart' as menu;

class PopMenu {
  static PopupMenuItem<T> buildItem<T>({
    required BuildContext context,
    required T value,
  }) {
    menu.ItemMenu itemMenu = value is menu.MenuTodo
        ? value.getItemMenu(context)
        : (value as menu.MenuItem).getItemMenu(context);
    return PopupMenuItem<T>(
      value: value,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        horizontalTitleGap: 0,
        leading: Icon(itemMenu.icon),
        title: Text(itemMenu.text),
      ),
    );
  }
}
