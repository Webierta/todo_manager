import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  String name;

  @HiveField(1, defaultValue: false)
  bool done;

  @HiveField(2, defaultValue: false)
  bool priority;

  Item({required this.name, this.done = false, this.priority = false});

  Map<String, dynamic> toJson() => {
        'name': name,
        'done': done,
        'priority': priority,
      };

  factory Item.fromJson(Map<String, dynamic> json) =>
      Item(name: json['name'], done: json['done'], priority: json['priority']);
}
