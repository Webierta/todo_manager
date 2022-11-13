import 'package:flutter/material.dart';

class PopMenu {
  static PopupMenuItem<T> buildItem<T>({
    required T value,
    required IconData iconData,
    required String text,
  }) {
    return PopupMenuItem<T>(
      value: value,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 2),
        horizontalTitleGap: 0,
        leading: Icon(iconData),
        title: Text(text),
      ),
    );
  }
}
