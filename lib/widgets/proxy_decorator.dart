import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_color.dart';

class ProxyDecorator {
  static Widget builder(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: AppColor.primary50,
          textStyle: const TextStyle(color: Colors.black),
          shadowColor: AppColor.primaryColor,
          child: child,
        );
      },
      child: IconTheme(
        data: const IconThemeData(color: Colors.black),
        child: child,
      ),
    );
  }
}
