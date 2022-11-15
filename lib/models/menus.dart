import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemMenu {
  final String text;
  final IconData icon;
  const ItemMenu({required this.text, required this.icon});
}

enum MenuTodo { sortAZ, sortDone, sortDate, export, import, deleteAll }

extension MenuExtension on MenuTodo {
  ItemMenu getItemMenu(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    switch (this) {
      case MenuTodo.sortAZ:
        return ItemMenu(text: appLang.sortAZ, icon: Icons.sort_by_alpha);
      case MenuTodo.sortDone:
        return ItemMenu(text: appLang.sortDone, icon: Icons.rule);
      case MenuTodo.sortDate:
        return ItemMenu(text: appLang.sortDate, icon: Icons.today);
      case MenuTodo.export:
        return ItemMenu(text: appLang.exportTask, icon: Icons.file_download);
      case MenuTodo.import:
        return ItemMenu(text: appLang.importTask, icon: Icons.file_upload);
      case MenuTodo.deleteAll:
        return ItemMenu(text: appLang.deleteAll, icon: Icons.delete_forever);
    }
  }
}

enum MenuItem { checkAll, uncheckAll, sortAZ, sortPriority, deleteAll }

extension MenuItemExtension on MenuItem {
  ItemMenu getItemMenu(BuildContext context) {
    AppLocalizations appLang = AppLocalizations.of(context)!;
    switch (this) {
      case MenuItem.sortAZ:
        return ItemMenu(text: appLang.sortAZ, icon: Icons.sort_by_alpha);
      case MenuItem.sortPriority:
        return ItemMenu(text: appLang.sortPriority, icon: Icons.priority_high);
      case MenuItem.checkAll:
        return ItemMenu(text: appLang.checkAll, icon: Icons.check_box_outlined);
      case MenuItem.uncheckAll:
        return ItemMenu(text: appLang.uncheckAll, icon: Icons.check_box_outline_blank);
      case MenuItem.deleteAll:
        return ItemMenu(text: appLang.deleteAll, icon: Icons.delete_forever);
    }
  }
}
