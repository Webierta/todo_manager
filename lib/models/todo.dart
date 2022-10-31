import 'package:hive/hive.dart';

import 'item.dart';
import 'tag.dart';

part 'todo.g.dart';

// run: flutter packages pub run build_runner build

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String name;

  @HiveField(1, defaultValue: false)
  bool priority;

  @HiveField(2, defaultValue: [])
  List<Item> items = [];

  @HiveField(3, defaultValue: Tag.personal)
  Tag tag = Tag.personal;

  @HiveField(4, defaultValue: null)
  DateTime? date;

  Todo({required this.name, this.priority = false});

  double ratioItemsDone = 0;
}
