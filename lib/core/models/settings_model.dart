import 'package:hive/hive.dart';

part 'settings_model.g.dart';

enum VoiceAnnouncementMode {
  everyCount,
  every10,
  every33,
  every100,
  silent,
}

enum AppLanguage {
  english,
  urdu,
  arabic,
}

enum FiqhMethod {
  hanafi,
  shafii,
  maliki,
  hanbali,
}

enum PrayerCalculationMethod {
  karachi,
  muslimWorldLeague,
  makkah,
  egyptian,
  isna,
}

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  // Accessibility Settings
  @HiveField(0)
  bool highContrastMode;

  @HiveField(1)
  bool darkMode;

  @HiveField(2)
  bool extraLargeText;

  @HiveField(3)
  bool screenReaderOptimized;

  @HiveField(4)
  bool reduceMotion;

  @HiveField(5)
  bool largeButtons;

  // Voice Settings
  @HiveField(6)
  bool voiceFeedbackEnabled;

  @HiveField(7)
  double voiceSpeed;

  @HiveField(8)
  double voicePitch;

  @HiveField(9)
  double voiceVolume;

  @HiveField(10)
  int voiceAnnouncementModeIndex;

  // Language Settings
  @HiveField(11)
  int languageIndex;

  // Qibla Settings
  @HiveField(12)
  bool qiblaVoiceGuidance;

  @HiveField(13)
  bool qiblaVibrationGuidance;

  // Counter Settings
  @HiveField(14)
  bool vibrationEnabled;

  @HiveField(15)
  bool strongVibrationEnabled;

  @HiveField(16)
  int targetCount;

  @HiveField(17)
  bool targetNotifications;

  // Prayer Settings
  @HiveField(18)
  int fiqhMethodIndex;

  @HiveField(19)
  int calculationMethodIndex;

  @HiveField(20)
  bool prayerNotifications;

  @HiveField(21)
  bool adhanNotifications;

  // Misc
  @HiveField(22)
  String? selectedZikrId;

  @HiveField(23)
  String? lastCityName;

  @HiveField(24)
  double? lastLatitude;

  @HiveField(25)
  double? lastLongitude;

  SettingsModel({
    this.highContrastMode = false,
    this.darkMode = true,
    this.extraLargeText = false,
    this.screenReaderOptimized = true,
    this.reduceMotion = false,
    this.largeButtons = true,
    this.voiceFeedbackEnabled = true,
    this.voiceSpeed = 0.5,
    this.voicePitch = 1.0,
    this.voiceVolume = 1.0,
    this.voiceAnnouncementModeIndex = 0,
    this.languageIndex = 0,
    this.qiblaVoiceGuidance = true,
    this.qiblaVibrationGuidance = true,
    this.vibrationEnabled = true,
    this.strongVibrationEnabled = true,
    this.targetCount = 0,
    this.targetNotifications = true,
    this.fiqhMethodIndex = 0,
    this.calculationMethodIndex = 0,
    this.prayerNotifications = true,
    this.adhanNotifications = true,
    this.selectedZikrId,
    this.lastCityName,
    this.lastLatitude,
    this.lastLongitude,
  });

  VoiceAnnouncementMode get voiceAnnouncementMode =>
      VoiceAnnouncementMode.values[voiceAnnouncementModeIndex.clamp(
        0,
        VoiceAnnouncementMode.values.length - 1,
      )];

  set voiceAnnouncementMode(VoiceAnnouncementMode mode) {
    voiceAnnouncementModeIndex = mode.index;
    save();
  }

  AppLanguage get language =>
      AppLanguage.values[languageIndex.clamp(0, AppLanguage.values.length - 1)];

  set language(AppLanguage lang) {
    languageIndex = lang.index;
    save();
  }

  FiqhMethod get fiqhMethod =>
      FiqhMethod.values[fiqhMethodIndex.clamp(0, FiqhMethod.values.length - 1)];

  set fiqhMethod(FiqhMethod method) {
    fiqhMethodIndex = method.index;
    save();
  }

  PrayerCalculationMethod get calculationMethod => PrayerCalculationMethod
      .values[calculationMethodIndex.clamp(
        0,
        PrayerCalculationMethod.values.length - 1,
      )];

  set calculationMethod(PrayerCalculationMethod method) {
    calculationMethodIndex = method.index;
    save();
  }

  SettingsModel copyWith({
    bool? highContrastMode,
    bool? darkMode,
    bool? extraLargeText,
    bool? screenReaderOptimized,
    bool? reduceMotion,
    bool? largeButtons,
    bool? voiceFeedbackEnabled,
    double? voiceSpeed,
    double? voicePitch,
    double? voiceVolume,
    int? voiceAnnouncementModeIndex,
    int? languageIndex,
    bool? qiblaVoiceGuidance,
    bool? qiblaVibrationGuidance,
    bool? vibrationEnabled,
    bool? strongVibrationEnabled,
    int? targetCount,
    bool? targetNotifications,
    int? fiqhMethodIndex,
    int? calculationMethodIndex,
    bool? prayerNotifications,
    bool? adhanNotifications,
    String? selectedZikrId,
    String? lastCityName,
    double? lastLatitude,
    double? lastLongitude,
  }) {
    return SettingsModel(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      darkMode: darkMode ?? this.darkMode,
      extraLargeText: extraLargeText ?? this.extraLargeText,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      largeButtons: largeButtons ?? this.largeButtons,
      voiceFeedbackEnabled: voiceFeedbackEnabled ?? this.voiceFeedbackEnabled,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      voicePitch: voicePitch ?? this.voicePitch,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      voiceAnnouncementModeIndex:
          voiceAnnouncementModeIndex ?? this.voiceAnnouncementModeIndex,
      languageIndex: languageIndex ?? this.languageIndex,
      qiblaVoiceGuidance: qiblaVoiceGuidance ?? this.qiblaVoiceGuidance,
      qiblaVibrationGuidance:
          qiblaVibrationGuidance ?? this.qiblaVibrationGuidance,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      strongVibrationEnabled:
          strongVibrationEnabled ?? this.strongVibrationEnabled,
      targetCount: targetCount ?? this.targetCount,
      targetNotifications: targetNotifications ?? this.targetNotifications,
      fiqhMethodIndex: fiqhMethodIndex ?? this.fiqhMethodIndex,
      calculationMethodIndex:
          calculationMethodIndex ?? this.calculationMethodIndex,
      prayerNotifications: prayerNotifications ?? this.prayerNotifications,
      adhanNotifications: adhanNotifications ?? this.adhanNotifications,
      selectedZikrId: selectedZikrId ?? this.selectedZikrId,
      lastCityName: lastCityName ?? this.lastCityName,
      lastLatitude: lastLatitude ?? this.lastLatitude,
      lastLongitude: lastLongitude ?? this.lastLongitude,
    );
  }
}
