// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Todo(
      name: fields[0] as String,
      priority: fields[1] == null ? false : fields[1] as bool,
    )
      ..items = fields[2] == null ? [] : (fields[2] as List).cast<Item>()
      ..tag = fields[3] == null ? Tag.personal : fields[3] as Tag
      ..date = fields[4] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.priority)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.tag)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
