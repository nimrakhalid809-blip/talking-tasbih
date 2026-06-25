// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 2;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; ++i) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      highContrastMode: fields[0] as bool,
      darkMode: fields[1] as bool,
      extraLargeText: fields[2] as bool,
      screenReaderOptimized: fields[3] as bool,
      reduceMotion: fields[4] as bool,
      largeButtons: fields[5] as bool,
      voiceFeedbackEnabled: fields[6] as bool,
      voiceSpeed: fields[7] as double,
      voicePitch: fields[8] as double,
      voiceVolume: fields[9] as double,
      voiceAnnouncementModeIndex: fields[10] as int,
      languageIndex: fields[11] as int,
      qiblaVoiceGuidance: fields[12] as bool,
      qiblaVibrationGuidance: fields[13] as bool,
      vibrationEnabled: fields[14] as bool,
      strongVibrationEnabled: fields[15] as bool,
      targetCount: fields[16] as int,
      targetNotifications: fields[17] as bool,
      fiqhMethodIndex: fields[18] as int,
      calculationMethodIndex: fields[19] as int,
      prayerNotifications: fields[20] as bool,
      adhanNotifications: fields[21] as bool,
      selectedZikrId: fields[22] as String?,
      lastCityName: fields[23] as String?,
      lastLatitude: fields[24] as double?,
      lastLongitude: fields[25] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.highContrastMode)
      ..writeByte(1)
      ..write(obj.darkMode)
      ..writeByte(2)
      ..write(obj.extraLargeText)
      ..writeByte(3)
      ..write(obj.screenReaderOptimized)
      ..writeByte(4)
      ..write(obj.reduceMotion)
      ..writeByte(5)
      ..write(obj.largeButtons)
      ..writeByte(6)
      ..write(obj.voiceFeedbackEnabled)
      ..writeByte(7)
      ..write(obj.voiceSpeed)
      ..writeByte(8)
      ..write(obj.voicePitch)
      ..writeByte(9)
      ..write(obj.voiceVolume)
      ..writeByte(10)
      ..write(obj.voiceAnnouncementModeIndex)
      ..writeByte(11)
      ..write(obj.languageIndex)
      ..writeByte(12)
      ..write(obj.qiblaVoiceGuidance)
      ..writeByte(13)
      ..write(obj.qiblaVibrationGuidance)
      ..writeByte(14)
      ..write(obj.vibrationEnabled)
      ..writeByte(15)
      ..write(obj.strongVibrationEnabled)
      ..writeByte(16)
      ..write(obj.targetCount)
      ..writeByte(17)
      ..write(obj.targetNotifications)
      ..writeByte(18)
      ..write(obj.fiqhMethodIndex)
      ..writeByte(19)
      ..write(obj.calculationMethodIndex)
      ..writeByte(20)
      ..write(obj.prayerNotifications)
      ..writeByte(21)
      ..write(obj.adhanNotifications)
      ..writeByte(22)
      ..write(obj.selectedZikrId)
      ..writeByte(23)
      ..write(obj.lastCityName)
      ..writeByte(24)
      ..write(obj.lastLatitude)
      ..writeByte(25)
      ..write(obj.lastLongitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
