class AppConstants {
  static const String appName = 'Talking Tasbih Counter';
  static const String appSubtitle = 'Accessible Spiritual Companion';
  static const String version = '1.0.0';

  static const String hiveZikrsKey = 'zikrs';
  static const String hiveHistoryKey = 'history';
  static const String hiveSettingsKey = 'settings';

  static const double minTouchTarget = 48.0;
  static const double preferredTouchTarget = 56.0;
  static const double largeTouchTarget = 64.0;
  static const double tabletTouchTarget = 72.0;

  static const double minCounterFontSize = 72.0;
  static const double maxCounterFontSize = 120.0;
  static const double counterButtonSize = 150.0;
  static const double largeCounterButtonSize = 180.0;

  static const List<int> defaultTargets = [33, 99, 100, 300, 500, 1000];
  static const List<int> milestoneCounts = [33, 99, 100];

  static const Duration voiceAnnouncementDelay = Duration(milliseconds: 100);
  static const Duration hapticFeedbackDuration = Duration(milliseconds: 10);
  static const Duration strongHapticDuration = Duration(milliseconds: 100);

  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;
}
