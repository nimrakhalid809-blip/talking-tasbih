import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/widgets/accessible_widgets.dart';
import '../../history/screens/history_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _announceScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _announceScreen();
    }
  }

  void _announceScreen() async {
    final settings = ref.read(settingsProvider);
    if (settings.voiceFeedbackEnabled) {
      final tts = ref.read(ttsServiceProvider);
      await Future.delayed(const Duration(milliseconds: 500));
      await tts.announceScreen('Settings', settings.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Semantics(
      label: 'Settings screen',
      container: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAccessibilitySection(settings),
              const SizedBox(height: 24),
              _buildVoiceSection(settings),
              const SizedBox(height: 24),
              _buildLanguageSection(settings),
              const SizedBox(height: 24),
              _buildCounterSection(settings),
              const SizedBox(height: 24),
              _buildQiblaSection(settings),
              const SizedBox(height: 24),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(SettingsModel settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Accessibility', Icons.accessibility),
            const Divider(),
            AccessibleSwitch(
              label: 'High Contrast Mode',
              hint: 'Optimizes colors for better visibility',
              value: settings.highContrastMode,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setHighContrastMode(v);
                _applyVoiceSetting();
              },
            ),
            AccessibleSwitch(
              label: 'Dark Mode',
              value: settings.darkMode,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setDarkMode(v);
              },
            ),
            AccessibleSwitch(
              label: 'Extra Large Text',
              hint: 'Increases text size throughout the app',
              value: settings.extraLargeText,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setExtraLargeText(v);
              },
            ),
            AccessibleSwitch(
              label: 'Large Buttons',
              hint: 'Makes buttons easier to tap',
              value: settings.largeButtons,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setLargeButtons(v);
              },
            ),
            AccessibleSwitch(
              label: 'Screen Reader Optimization',
              hint: 'Optimizes announcements for screen readers',
              value: settings.screenReaderOptimized,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setScreenReaderOptimized(v);
              },
            ),
            AccessibleSwitch(
              label: 'Reduce Motion',
              hint: 'Minimizes animations',
              value: settings.reduceMotion,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setReduceMotion(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSection(SettingsModel settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Voice Settings', Icons.record_voice_over),
            const Divider(),
            AccessibleSwitch(
              label: 'Voice Feedback',
              hint: 'Announces counts and status through voice',
              value: settings.voiceFeedbackEnabled,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setVoiceFeedbackEnabled(v);
              },
            ),
            const SizedBox(height: 8),
            AccessibleSlider(
              label: 'Voice Speed',
              value: settings.voiceSpeed,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setVoiceSpeed(v);
                _applyVoiceSetting();
              },
              valueFormatter: (v) => '${(v * 100).round()}%',
            ),
            const SizedBox(height: 8),
            AccessibleSlider(
              label: 'Voice Pitch',
              value: settings.voicePitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setVoicePitch(v);
                _applyVoiceSetting();
              },
              valueFormatter: (v) => v.toStringAsFixed(1),
            ),
            const SizedBox(height: 8),
            AccessibleSlider(
              label: 'Voice Volume',
              value: settings.voiceVolume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setVoiceVolume(v);
                _applyVoiceSetting();
              },
              valueFormatter: (v) => '${(v * 100).round()}%',
            ),
            const SizedBox(height: 16),
            _buildVoiceAnnouncementModeSelector(settings),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceAnnouncementModeSelector(SettingsModel settings) {
    final modes = VoiceAnnouncementMode.values;
    final labels = {
      VoiceAnnouncementMode.everyCount: 'Every Count',
      VoiceAnnouncementMode.every10: 'Every 10 Counts',
      VoiceAnnouncementMode.every33: 'Every 33 Counts',
      VoiceAnnouncementMode.every100: 'Every 100 Counts',
      VoiceAnnouncementMode.silent: 'Silent Mode',
    };

    return Semantics(
      label: 'Voice Announcement Frequency: ${labels[settings.voiceAnnouncementMode]}',
      hint: 'Tap to change when counts are announced',
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Announcement Frequency',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: DropdownButton<VoiceAnnouncementMode>(
          value: settings.voiceAnnouncementMode,
          items: modes
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(labels[m] ?? ''),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              ref.read(settingsProvider.notifier).setVoiceAnnouncementMode(v);
            }
          },
          isExpanded: true,
          underline: const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildLanguageSection(SettingsModel settings) {
    final languages = AppLanguage.values;
    final labels = {
      AppLanguage.english: 'English',
      AppLanguage.urdu: 'اردو (Urdu)',
      AppLanguage.arabic: 'العربية (Arabic)',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Language', Icons.language),
            const Divider(),
            Semantics(
              label: 'Language: ${labels[settings.language]}',
              hint: 'Tap to change the app language',
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Voice Language',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: DropdownButton<AppLanguage>(
                  value: settings.language,
                  items: languages
                      .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(labels[l] ?? ''),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(settingsProvider.notifier).setLanguage(v);
                      _applyVoiceSetting();
                    }
                  },
                  isExpanded: true,
                  underline: const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection(SettingsModel settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Counter Settings', Icons.touch_app),
            const Divider(),
            AccessibleSwitch(
              label: 'Vibration',
              hint: 'Vibrates on each tap',
              value: settings.vibrationEnabled,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setVibrationEnabled(v);
              },
            ),
            AccessibleSwitch(
              label: 'Strong Vibration at Milestones',
              hint: 'Stronger vibration at 33, 99, 100 counts',
              value: settings.strongVibrationEnabled,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setStrongVibrationEnabled(v);
              },
            ),
            AccessibleSwitch(
              label: 'Target Notifications',
              hint: 'Announces when target is reached',
              value: settings.targetNotifications,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setTargetNotifications(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQiblaSection(SettingsModel settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Qibla Settings', Icons.explore),
            const Divider(),
            AccessibleSwitch(
              label: 'Voice Guidance',
              hint: 'Announces direction changes',
              value: settings.qiblaVoiceGuidance,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setQiblaVoiceGuidance(v);
              },
            ),
            AccessibleSwitch(
              label: 'Vibration Guidance',
              hint: 'Vibrates when aligned with Qibla',
              value: settings.qiblaVibrationGuidance,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setQiblaVibrationGuidance(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('About', Icons.info_outline),
            const Divider(),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openHistoryScreen(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'View History',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showAboutDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'About App',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyVoiceSetting() async {
    final settings = ref.read(settingsProvider);
    final tts = ref.read(ttsServiceProvider);
    await tts.setVoiceSettings(settings);
  }

  void _openHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const HistoryScreen()),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Talking Tasbih Counter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Accessible Spiritual Companion'),
            SizedBox(height: 16),
            Text(
              'Designed for blind, visually impaired, and accessibility-focused Muslim users. '
              'Fully accessible with screen readers, high contrast mode, and large touch targets.',
            ),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
