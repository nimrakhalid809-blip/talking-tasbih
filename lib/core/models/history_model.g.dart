// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryModelAdapter extends TypeAdapter<HistoryModel> {
  @override
  final int typeId = 1;

  @override
  HistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; ++i) reader.readByte(): reader.read(),
    };
    return HistoryModel(
      id: fields[0] as String,
      zikrId: fields[1] as String,
      zikrName: fields[2] as String,
      count: fields[3] as int,
      target: fields[4] as int,
      targetCompleted: fields[5] as bool,
      startedAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.zikrId)
      ..writeByte(2)
      ..write(obj.zikrName)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.target)
      ..writeByte(5)
      ..write(obj.targetCompleted)
      ..writeByte(6)
      ..write(obj.startedAt)
      ..writeByte(7)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
