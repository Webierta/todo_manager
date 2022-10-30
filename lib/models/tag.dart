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
  //String get name => describeEnum(this);
  //String get name => this.name;
  /* String get name {
    switch (this) {
      case Tag.personal:
        return 'Personal';
      case Tag.work:
        return 'Work';
      default:
        return 'Personal';
    }    
  } */

  /* get sorted {
    var x = Tag.values.sort(((a, b) => a.name.compareTo(b.name)));
    return x;
  } */

  Color get color {
    for (var i = 0; i < Tag.values.length; i++) {
      if (this == Tag.values[i]) {
        return AppColor.tagColors[i];
      }
    }
    return Colors.blue;

    /* switch (this) {
      case Tag.personal:
        return Colors.red;
      case Tag.work:
        return Colors.blue;
      case Tag.shopping:
        return Colors.amber;
      case Tag.idea:
        return Colors.yellowAccent;
      case Tag.project:
        return Colors.indigo;
      case Tag.meeting:
        return Colors.purple;
      case Tag.event:
        return Colors.green;
      case Tag.anniversary:
        return Colors.amber;
      case Tag.family:
        return Colors.red;
      case Tag.friends:
        return Colors.green;
      case Tag.social:
        return Colors.amber;
      case Tag.house:
        return Colors.red;
      case Tag.community:
        return Colors.green;
      case Tag.business:
        return Colors.amber;
      case Tag.party:
        return Colors.red;
      case Tag.holidays:
        return Colors.green;
      case Tag.finance:
        return Colors.amber;
      case Tag.health:
        return Colors.green;
      case Tag.sport:
        return Colors.amber;
      case Tag.nature:
        return Colors.red;
      case Tag.pet:
        return Colors.green;
      default:
        return Colors.blue;
    } */
  }
}
