import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  final String name;

  @HiveField(1, defaultValue: false)
  bool done;

  Item({required this.name, this.done = false});
}
