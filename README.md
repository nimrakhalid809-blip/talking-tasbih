# Talking Tasbih Counter

**Accessible Spiritual Companion for Muslim Users**

A fully accessible Flutter application designed primarily for blind, visually impaired, low-vision, elderly, and accessibility-focused Muslim users.

## Features

### Talking Tasbih Counter
- Large, accessible count button with voice and haptic feedback
- Target setting (33, 99, 100, 300, 500, 1000, or custom)
- Voice announcements in English, Urdu, and Arabic
- Automatic history tracking
- Zikr management (default and custom)

### Qibla Direction
- Compass integration with accurate Qibla direction
- Voice guidance ("Turn left", "Turn right", "Perfect alignment")
- Vibration feedback when aligned
- High contrast compass display

### Prayer Times
- Automatic location detection
- Multiple calculation methods (Karachi, MWL, Makkah, Egyptian, ISNA)
- Fiqh selection (Hanafi, Shafi'i, Maliki, Hanbali)
- Next prayer countdown
- Beautiful prayer-specific icons and colors

### Accessibility Features
- Full TalkBack/VoiceOver support
- Screen reader optimized sematics
- High contrast mode
- Extra large text option
- Large touch targets (48-64 dp minimum)
- Reduce motion option
- Multi-language voice support (English, Urdu, Arabic)

## Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── models/
│   │   ├── zikr_model.dart
│   │   ├── history_model.dart
│   │   ├── settings_model.dart
│   │   └── prayer_time_model.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   ├── tts_service.dart
│   │   ├── haptic_service.dart
│   │   ├── qibla_service.dart
│   │   └── prayer_time_service.dart
│   ├── providers/
│   │   └── providers.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── accessibility_utils.dart
│   └── widgets/
│       └── accessible_widgets.dart
├── features/
│   ├── counter/
│   │   └── screens/
│   │       └── counter_screen.dart
│   ├── qibla/
│   │   └── screens/
│   │       └── qibla_screen.dart
│   ├── prayer/
│   │   └── screens/
│   │       └── prayer_times_screen.dart
│   ├── settings/
│   │   └── screens/
│   │       └── settings_screen.dart
│   └── history/
│       └── screens/
│           └── history_screen.dart
├── l10n/
│   └── app_localizations.dart
└── main.dart
```

## Technologies Used

- **Flutter** - Latest Stable
- **Riverpod** - State Management
- **Hive** - Local Database
- **Flutter TTS** - Text-to-Speech
- **Vibration** - Haptic Feedback
- **Geolocator** - Location Services
- **Flutter Compass** - Qibla Direction

## Getting Started

1. Ensure Flutter is installed on your system
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Accessibility Implementation

Every widget in this app uses Flutter Semantics:

```dart
Semantics(
  label: "Tap to increase Tasbih count",
  hint: "Double tap to count",
  button: true,
  child: // widget
)
```

### Touch Targets
- Minimum: 48dp (Android TalkBack requirement)
- Preferred: 56dp
- Large mode: 64dp

### Supported Screen Readers
- Android TalkBack
- iOS VoiceOver

## Platform Support

- Android (minSdk 21)
- iOS
- Tablets
- Foldables

## License

This application is designed for accessibility and spiritual use by the Muslim community.

## Default Zikrs

1. SubhanAllah ( سُبْحَانَ ٱللَّٰهِ )
2. Alhamdulillah ( ٱلْحَمْدُ لِلَّٰهِ )
3. Allahu Akbar ( ٱللَّٰهُ أَكْبَرُ )
4. Astaghfirullah ( أَسْتَغْفِرُ ٱللَّٰهَ )
5. La Ilaha Illallah ( لَا إِلَٰهَ إِلَّا ٱللَّٰهُ )
6. Durood Sharif ( صَلَّى ٱللَّٰهُ عَلَيْهِ وَسَلَّمَ )
