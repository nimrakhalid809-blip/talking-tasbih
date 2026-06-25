// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zikr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZikrModelAdapter extends TypeAdapter<ZikrModel> {
  @override
  final int typeId = 0;

  @override
  ZikrModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; ++i) reader.readByte(): reader.read(),
    };
    return ZikrModel(
      id: fields[0] as String,
      name: fields[1] as String,
      transliteration: fields[2] as String,
      meaning: fields[3] as String,
      isDefault: fields[4] as bool,
      isFavorite: fields[5] as bool,
      sortOrder: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ZikrModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.transliteration)
      ..writeByte(3)
      ..write(obj.meaning)
      ..writeByte(4)
      ..write(obj.isDefault)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.sortOrder)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZikrModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
