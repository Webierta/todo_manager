// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 2;

  @override
  Tag read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Tag.personal;
      case 1:
        return Tag.work;
      case 2:
        return Tag.shopping;
      case 3:
        return Tag.idea;
      case 4:
        return Tag.project;
      case 5:
        return Tag.meeting;
      case 6:
        return Tag.event;
      case 7:
        return Tag.anniversary;
      case 8:
        return Tag.family;
      case 9:
        return Tag.friends;
      case 10:
        return Tag.social;
      case 11:
        return Tag.house;
      case 12:
        return Tag.community;
      case 13:
        return Tag.business;
      case 14:
        return Tag.party;
      case 15:
        return Tag.holidays;
      case 16:
        return Tag.finance;
      case 17:
        return Tag.health;
      case 18:
        return Tag.sport;
      case 19:
        return Tag.nature;
      case 20:
        return Tag.pet;
      default:
        return Tag.personal;
    }
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    switch (obj) {
      case Tag.personal:
        writer.writeByte(0);
        break;
      case Tag.work:
        writer.writeByte(1);
        break;
      case Tag.shopping:
        writer.writeByte(2);
        break;
      case Tag.idea:
        writer.writeByte(3);
        break;
      case Tag.project:
        writer.writeByte(4);
        break;
      case Tag.meeting:
        writer.writeByte(5);
        break;
      case Tag.event:
        writer.writeByte(6);
        break;
      case Tag.anniversary:
        writer.writeByte(7);
        break;
      case Tag.family:
        writer.writeByte(8);
        break;
      case Tag.friends:
        writer.writeByte(9);
        break;
      case Tag.social:
        writer.writeByte(10);
        break;
      case Tag.house:
        writer.writeByte(11);
        break;
      case Tag.community:
        writer.writeByte(12);
        break;
      case Tag.business:
        writer.writeByte(13);
        break;
      case Tag.party:
        writer.writeByte(14);
        break;
      case Tag.holidays:
        writer.writeByte(15);
        break;
      case Tag.finance:
        writer.writeByte(16);
        break;
      case Tag.health:
        writer.writeByte(17);
        break;
      case Tag.sport:
        writer.writeByte(18);
        break;
      case Tag.nature:
        writer.writeByte(19);
        break;
      case Tag.pet:
        writer.writeByte(20);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
