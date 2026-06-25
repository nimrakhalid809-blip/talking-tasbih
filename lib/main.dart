import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/models/models.dart';
import 'core/providers/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/counter/screens/counter_screen.dart';
import 'features/qibla/screens/qibla_screen.dart';
import 'features/prayer/screens/prayer_times_screen.dart';
import 'features/settings/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: TalkingTasbihApp(),
    ),
  );
}

class TalkingTasbihApp extends ConsumerStatefulWidget {
  const TalkingTasbihApp({super.key});

  @override
  ConsumerState<TalkingTasbihApp> createState() => _TalkingTasbihAppState();
}

class _TalkingTasbihAppState extends ConsumerState<TalkingTasbihApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final storage = ref.read(storageServiceProvider);
    await storage.initialize();

    final settings = storage.getSettings();
    final tts = ref.read(ttsServiceProvider);
    await tts.initialize();

    if (settings.voiceFeedbackEnabled) {
      await tts.setVoiceSettings(settings);
    }

    final haptic = ref.read(hapticServiceProvider);
    await haptic.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    final theme = settings.darkMode
        ? AppTheme.darkTheme(
            Brightness.dark,
            highContrast: settings.highContrastMode,
            extraLargeText: settings.extraLargeText,
            largeButtons: settings.largeButtons,
          )
        : AppTheme.lightTheme(
            highContrast: settings.highContrastMode,
            extraLargeText: settings.extraLargeText,
            largeButtons: settings.largeButtons,
          );

    return MaterialApp(
      title: 'Talking Tasbih Counter',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    CounterScreen(),
    QiblaScreen(),
    PrayerTimesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    final announcement = _getTabAnnouncement(index);
    SemanticsService.announce(announcement, TextDirection.ltr);

    final settings = ref.read(settingsProvider);
    if (settings.voiceFeedbackEnabled) {
      final tts = ref.read(ttsServiceProvider);
      tts.speak(announcement);
    }
  }

  String _getTabAnnouncement(int index) {
    switch (index) {
      case 0:
        return 'Talking Tasbih Counter';
      case 1:
        return 'Qibla Direction';
      case 2:
        return 'Prayer Times';
      case 3:
        return 'Settings';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Semantics(
      label: 'Talking Tasbih Counter main screen',
      container: true,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Semantics(
          label: 'Navigation bar',
          hint: 'Use one finger left and right swipe to navigate between tabs',
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabChanged,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: settings.extraLargeText ? 16 : 12,
              unselectedFontSize: settings.extraLargeText ? 14 : 10,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
              items: [
                BottomNavigationBarItem(
                  icon: Semantics(
                    label: 'Counter',
                    button: true,
                    selected: _currentIndex == 0,
                    child: const Icon(Icons.fingerprint),
                  ),
                  label: 'Counter',
                ),
                BottomNavigationBarItem(
                  icon: Semantics(
                    label: 'Qibla',
                    button: true,
                    selected: _currentIndex == 1,
                    child: const Icon(Icons.explore),
                  ),
                  label: 'Qibla',
                ),
                BottomNavigationBarItem(
                  icon: Semantics(
                    label: 'Prayer',
                    button: true,
                    selected: _currentIndex == 2,
                    child: const Icon(Icons.mosque),
                  ),
                  label: 'Prayer',
                ),
                BottomNavigationBarItem(
                  icon: Semantics(
                    label: 'Settings',
                    button: true,
                    selected: _currentIndex == 3,
                    child: const Icon(Icons.settings),
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
