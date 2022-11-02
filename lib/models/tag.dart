import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../theme/app_color.dart';

part 'tag.g.dart';

@HiveType(typeId: 2)
enum Tag {
  @HiveField(0)
  personal,

  @HiveField(1)
  work,

  @HiveField(2)
  shopping,

  @HiveField(3)
  idea,

  @HiveField(4)
  project,

  @HiveField(5)
  meeting,

  @HiveField(6)
  event,

  @HiveField(7)
  anniversary,

  @HiveField(8)
  family,

  @HiveField(9)
  friends,

  @HiveField(10)
  social,

  @HiveField(11)
  house,

  @HiveField(12)
  community,

  @HiveField(13)
  business,

  @HiveField(14)
  party,

  @HiveField(15)
  holidays,

  @HiveField(16)
  finance,

  @HiveField(17)
  health,

  @HiveField(18)
  sport,

  @HiveField(19)
  nature,

  @HiveField(20)
  pet,
}

extension TagExtension on Tag {
  Color get color {
    for (var i = 0; i < Tag.values.length; i++) {
      if (this == Tag.values[i]) {
        assert(AppColor.tagColors.length >= Tag.values.length);
        return AppColor.tagColors[i];
      }
    }
    return Colors.blue;
  }
}
