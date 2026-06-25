import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get appName => 'Talking Tasbih Counter';
  String get appSubtitle => 'Accessible Spiritual Companion';

  String get counterTab => 'Counter';
  String get qiblaTab => 'Qibla';
  String get prayerTab => 'Prayer';
  String get settingsTab => 'Settings';

  String get tapToCount => 'TAP TO COUNT';
  String get currentZikr => 'Current Zikr';
  String get selectZikr => 'Select Zikr';
  String get setTarget => 'Set Target';
  String get noTarget => 'No Target';
  String get custom => 'Custom';
  String get reset => 'Reset';
  String get undoReset => 'Undo Reset';
  String get resetCurrentTasbih => 'Reset Current Tasbih?';
  String get yes => 'Yes';
  String get no => 'No';

  String get zikrSubhanAllah => 'SubhanAllah';
  String get zikrAlhamdulillah => 'Alhamdulillah';
  String get zikrAllahuAkbar => 'Allahu Akbar';
  String get zikrAstaghfirullah => 'Astaghfirullah';
  String get zikrLaIlahaIllallah => 'La Ilaha Illallah';
  String get zikrDuroodSharif => 'Durood Sharif';

  String get history => 'History';
  String get noHistoryFound => 'No history found';
  String get searchHistory => 'Search History';
  String get clearHistory => 'Clear History';
  String get exportHistory => 'Export History';
  String get clearAllHistory => 'Clear All History?';
  String get thisActionCannotBeUndone => 'This action cannot be undone.';
  String get clear => 'Clear';

  String get qiblaDirection => 'Qibla Direction';
  String get facingKaaba => 'Facing Kaaba';
  String get turnLeft => 'Turn Left';
  String get turnRight => 'Turn Right';
  String get turnSlightlyLeft => 'Turn Slightly Left';
  String get turnSlightlyRight => 'Turn Slightly Right';
  String get perfectAlignment => 'Perfect Alignment';
  String get youAreFacingQibla => 'You are facing the Qibla';
  String get voiceGuidance => 'Voice Guidance';
  String get vibrationGuidance => 'Vibration Guidance';

  String get prayerTimes => 'Prayer Times';
  String get fajr => 'Fajr';
  String get sunrise => 'Sunrise';
  String get dhuhr => 'Dhuhr';
  String get asr => 'Asr';
  String get maghrib => 'Maghrib';
  String get isha => 'Isha';
  String get nextPrayer => 'Next Prayer';
  String get selectCalculationMethod => 'Select Calculation Method';
  String get selectFiqh => 'Select Fiqh';

  String get accessibilitySettings => 'Accessibility';
  String get highContrastMode => 'High Contrast Mode';
  String get darkMode => 'Dark Mode';
  String get lightMode => 'Light Mode';
  String get extraLargeText => 'Extra Large Text';
  String get screenReaderOptimization => 'Screen Reader Optimization';
  String get reduceMotion => 'Reduce Motion';
  String get largeButtons => 'Large Buttons';

  String get voiceSettings => 'Voice Settings';
  String get voiceFeedback => 'Voice Feedback';
  String get voiceSpeed => 'Voice Speed';
  String get voicePitch => 'Voice Pitch';
  String get voiceVolume => 'Voice Volume';
  String get announcementFrequency => 'Announcement Frequency';
  String get everyCount => 'Every Count';
  String get every10Counts => 'Every 10 Counts';
  String get every33Counts => 'Every 33 Counts';
  String get every100Counts => 'Every 100 Counts';
  String get silentMode => 'Silent Mode';

  String get languageSettings => 'Language';
  String get english => 'English';
  String get urdu => 'Urdu';
  String get arabic => 'Arabic';

  String get counterSettings => 'Counter Settings';
  String get vibration => 'Vibration';
  String get strongVibrationAtMilestones => 'Strong Vibration at Milestones';
  String get targetNotifications => 'Target Notifications';

  String get qiblaSettings => 'Qibla Settings';
  String get counterScreenTitle => 'Talking Tasbih Counter';
  String get prayerScreenTitle => 'Prayer Times';
  String get qiblaScreenTitle => 'Qibla Direction';
  String get settingsScreenTitle => 'Settings';

  String get congratulationsTargetCompleted => 'Congratulations. Target Completed.';
  String get counterReset => 'Counter reset.';
  String get counterRestored => 'Counter restored.';

  String get aboutApp => 'About App';
  String get viewHistory => 'View History';
  String get about => 'About';
  String get ok => 'OK';
  String get cancel => 'Cancel';
  String get save => 'Save';
  String get delete => 'Delete';
  String get edit => 'Edit';
  String get add => 'Add';
  String get change => 'Change';
  String get tryAgain => 'Try Again';
  String get refresh => 'Refresh';
  String get addCustomZikr => 'Add Custom Zikr';
  String get editZikr => 'Edit Zikr';
  String get deleteZikr => 'Delete Zikr';
  String get zikrName => 'Zikr Name';
  String get arabicText => 'Arabic Text';
  String get transliteration => 'Transliteration';
  String get meaning => 'Meaning';
  String get required => 'Required';
  String get optional => 'Optional';

  String get locationPermissionRequired => 'Location permission required';
  String get locationPermissionMessage => 'Please grant location permission to calculate accurate prayer times.';
  String get compassNotAvailable => 'Compass not available';
  String get loadingPrayerTimes => 'Calculating prayer times...';
  String get gettingLocation => 'Getting your location...';
  String get waitingForCompass => 'Waiting for compass...';
  String get targetComplete => 'Target Complete';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ur', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
