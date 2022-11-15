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

  String displayRatioPercentage() {
    RegExp regex = RegExp(r'([.]*0+)(?!.*\d)');
    return '${(ratioItemsDone * 100).toStringAsFixed(2).replaceAll(regex, '')}%';
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> itemsToJson = items.map((it) => it.toJson()).toList();
    if (date != null) {
      return {
        'name': name,
        'priority': priority,
        'items': itemsToJson,
        'tag': tag.name,
        'date': date!.toIso8601String(),
      };
    } else {
      return {
        'name': name,
        'priority': priority,
        'items': itemsToJson,
        'tag': tag.name,
      };
    }
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    Todo todo = Todo(name: json['name'], priority: json['priority']);

    json['items'].forEach((it) => todo.items.add(Item.fromJson(it)));

    todo.tag = Tag.values.firstWhere((t) => t.name == json['tag'], orElse: (() => Tag.personal));
    if (json['date'] != null) {
      todo.date = DateTime.parse(json['date']);
    }
    return todo;
  }
}
