import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/settings_model.dart';

class TtsService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en-US';
  bool _engineAvailable = false;
  List<String> _availableLanguages = [];

  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;
  bool get isEngineAvailable => _engineAvailable;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Check if TTS engine is available
      if (Platform.isAndroid) {
        final engines = await _flutterTts!.getEngines;
        debugPrint('Available TTS engines: $engines');
        if (engines == null || (engines is List && engines.isEmpty)) {
          debugPrint('No TTS engines available on this device');
          _isInitialized = true;
          return;
        }

        // Try to set a working engine if multiple are available
        if (engines is List && engines.isNotEmpty) {
          final engineName = engines.first.toString();
          debugPrint('Setting TTS engine: $engineName');
          try {
            await _flutterTts!.setEngine(engineName);
          } catch (e) {
            debugPrint('Could not set engine: $e, using default');
          }
        }
        _engineAvailable = true;
      } else {
        _engineAvailable = true;
      }

      // Handler setters do not return Futures; do not await them.
      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
        debugPrint('TTS started speaking');
      });

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
        debugPrint('TTS completed speaking');
      });

      _flutterTts!.setErrorHandler((error) {
        debugPrint('TTS Error: $error');
        _isSpeaking = false;
      });

      _flutterTts!.setCancelHandler(() {
        _isSpeaking = false;
        debugPrint('TTS cancelled');
      });

      await _configurePlatformSpecifics();

      // Get available languages
      try {
        final languages = await _flutterTts!.getLanguages;
        if (languages != null && languages is List) {
          _availableLanguages = languages.map((l) => l.toString()).toList();
          debugPrint('Available TTS languages: $_availableLanguages');
        }
      } catch (e) {
        debugPrint('Could not get languages: $e');
      }

      // Test a simple speak to verify TTS is actually working
      try {
        await _flutterTts!.awaitSpeakCompletion(true);
      } catch (e) {
        debugPrint('Could not set awaitSpeakCompletion: $e');
      }

      _isInitialized = true;
      debugPrint('TTS service initialized successfully');
    } catch (e) {
      debugPrint('TTS initialization failed: $e');
      _isInitialized = true;
    }
  }

  bool _isLanguageAvailable(String languageCode) {
    if (_availableLanguages.isEmpty) return true;
    return _availableLanguages.any((l) =>
        l.toLowerCase() == languageCode.toLowerCase() ||
        l.toLowerCase().startsWith(languageCode.toLowerCase().substring(0, 2)));
  }

  String _getFallbackLanguage(String preferredLanguage) {
    if (_isLanguageAvailable(preferredLanguage)) {
      return preferredLanguage;
    }

    // Try to find a match for the language prefix
    final prefix = preferredLanguage.substring(0, 2).toLowerCase();
    for (final lang in _availableLanguages) {
      if (lang.toLowerCase().startsWith(prefix)) {
        debugPrint('Using fallback language: $lang for $preferredLanguage');
        return lang;
      }
    }

    // Default to English
    debugPrint('Language $preferredLanguage not available, defaulting to en-US');
    return 'en-US';
  }

  Future<void> _configurePlatformSpecifics() async {
    if (Platform.isIOS) {
      try {
        // Keep shared instance call where available; avoid referencing enums
        // that may not exist for the current plugin version.
        await _flutterTts!.setSharedInstance(true);
      } catch (e) {
        debugPrint('Could not set shared instance on iOS: $e');
      }

      // NOTE: iOS audio category enums were removed because the previous
      // identifiers (IosTextToSpeechAudioPlaybackCategory, etc.) are not
      // available with the current flutter_tts version used in analysis.
      // If you need to set iOS audio categories, update flutter_tts and
      // re-introduce setIosAudioCategory using the correct enums for
      // that version inside a try/catch.
    }

    if (Platform.isAndroid) {
      await _flutterTts!.setQueueMode(1);
      // Ensure audio is not suppressed
      try {
        await _flutterTts!.setVolume(1.0);
      } catch (e) {
        debugPrint('Could not set volume: $e');
      }
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_flutterTts == null) return;

    final languageCodes = {
      AppLanguage.english: 'en-US',
      AppLanguage.urdu: 'ur-PK',
      AppLanguage.arabic: 'ar-SA',
    };

    final preferredLanguage = languageCodes[language] ?? 'en-US';
    _currentLanguage = _getFallbackLanguage(preferredLanguage);

    try {
      await _flutterTts!.setLanguage(_currentLanguage);
      debugPrint('TTS language set to: $_currentLanguage');
    } catch (e) {
      debugPrint('Failed to set TTS language: $e');
    }
  }

  Future<void> setVoiceSettings(SettingsModel settings) async {
    if (_flutterTts == null || !_engineAvailable) return;

    try {
      await _flutterTts!.setSpeechRate(settings.voiceSpeed);
      await _flutterTts!.setPitch(settings.voicePitch);
      await _flutterTts!.setVolume(settings.voiceVolume);
      await setLanguage(settings.language);
      debugPrint('Voice settings applied: speed=${settings.voiceSpeed}, pitch=${settings.voicePitch}, volume=${settings.voiceVolume}');
    } catch (e) {
      debugPrint('Failed to set voice settings: $e');
    }
  }

  Future<void> speak(String text, {bool awaitCompletion = false}) async {
    if (_flutterTts == null || !_isInitialized || !_engineAvailable) {
      debugPrint('TTS not available for speak: initialized=$_isInitialized, engine=$_engineAvailable');
      return;
    }

    if (text.isEmpty) return;

    try {
      await _flutterTts!.stop();
      _isSpeaking = true;

      debugPrint('Speaking: $text');

      // On Android, always await completion for more reliable speech
      if (Platform.isAndroid || awaitCompletion) {
        await _flutterTts!.speak(text);
      } else {
        _flutterTts!.speak(text);
      }
    } catch (e) {
      debugPrint('Failed to speak: $e');
      _isSpeaking = false;
    }
  }

  Future<void> speakCount(String zikrName, int count, AppLanguage language) async {
    if (!_engineAvailable) return;
    final text = _getCountAnnouncement(zikrName, count, language);
    await speak(text);
  }

  String _getCountAnnouncement(String zikrName, int count, AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return '$zikrName $count';
      case AppLanguage.urdu:
        return '$zikrName $count';
      case AppLanguage.arabic:
        return '$zikrName $count';
    }
  }

  Future<void> announceScreen(String screenName, AppLanguage language) async {
    if (!_engineAvailable) return;
    final text = _getScreenAnnouncement(screenName, language);
    await speak(text);
  }

  String _getScreenAnnouncement(String screenName, AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'Talking Tasbih Counter. $screenName screen.';
      case AppLanguage.urdu:
        return 'ٹاکنگ تسبیح کاؤنٹر۔ $screenName اسکرین۔';
      case AppLanguage.arabic:
        return 'عداد التسبيح الناطق. شاشة $screenName.';
    }
  }

  Future<void> announceTargetComplete(AppLanguage language) async {
    if (!_engineAvailable) return;
    final text = _getTargetCompleteMessage(language);
    await speak(text);
  }

  String _getTargetCompleteMessage(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'Congratulations. Target Completed.';
      case AppLanguage.urdu:
        return 'مبارک ہو۔ ٹارگیٹ مکمل ہو گیا۔';
      case AppLanguage.arabic:
        return 'مبروك. تم الهدف.';
    }
  }

  Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
    _isSpeaking = false;
  }

  void dispose() {
    _flutterTts = null;
    _isInitialized = false;
    _isSpeaking = false;
  }
}
