import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/services.dart';
import '../models/models.dart';

// Service Providers
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  final service = HapticService();
  ref.onDispose(() => service.dispose());
  return service;
});

final qiblaServiceProvider = Provider<QiblaService>((ref) {
  final service = QiblaService();
  ref.onDispose(() => service.dispose());
  return service;
});

final prayerTimeServiceProvider = Provider<PrayerTimeService>((ref) {
  final service = PrayerTimeService();
  ref.onDispose(() => service.dispose());
  return service;
});

// App Initialization Provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(storageServiceProvider);
  final tts = ref.read(ttsServiceProvider);
  final haptic = ref.read(hapticServiceProvider);

  await Future.wait([
    storage.initialize(),
    tts.initialize(),
    haptic.initialize(),
  ]);
});

// Settings Provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  final storage = ref.read(storageServiceProvider);
  return SettingsNotifier(storage);
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(_storage.getSettings());

  void updateSettings(SettingsModel newSettings) {
    state = newSettings;
    _storage.updateSettings(newSettings);
  }

  void setHighContrastMode(bool value) {
    state = state.copyWith(highContrastMode: value);
    _storage.updateSettings(state);
  }

  void setDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
    _storage.updateSettings(state);
  }

  void setExtraLargeText(bool value) {
    state = state.copyWith(extraLargeText: value);
    _storage.updateSettings(state);
  }

  void setVoiceSpeed(double value) {
    state = state.copyWith(voiceSpeed: value);
    _storage.updateSettings(state);
  }

  void setVoicePitch(double value) {
    state = state.copyWith(voicePitch: value);
    _storage.updateSettings(state);
  }

  void setVoiceVolume(double value) {
    state = state.copyWith(voiceVolume: value);
    _storage.updateSettings(state);
  }

  void setVoiceFeedbackEnabled(bool value) {
    state = state.copyWith(voiceFeedbackEnabled: value);
    _storage.updateSettings(state);
  }

  void setVoiceAnnouncementMode(VoiceAnnouncementMode mode) {
    state = state.copyWith(voiceAnnouncementModeIndex: mode.index);
    _storage.updateSettings(state);
  }

  void setLanguage(AppLanguage language) {
    state = state.copyWith(languageIndex: language.index);
    _storage.updateSettings(state);
  }

  void setVibrationEnabled(bool value) {
    state = state.copyWith(vibrationEnabled: value);
    _storage.updateSettings(state);
  }

  void setStrongVibrationEnabled(bool value) {
    state = state.copyWith(strongVibrationEnabled: value);
    _storage.updateSettings(state);
  }

  void setTargetCount(int value) {
    state = state.copyWith(targetCount: value);
    _storage.updateSettings(state);
  }

  void setTargetNotifications(bool value) {
    state = state.copyWith(targetNotifications: value);
    _storage.updateSettings(state);
  }

  void setQiblaVoiceGuidance(bool value) {
    state = state.copyWith(qiblaVoiceGuidance: value);
    _storage.updateSettings(state);
  }

  void setQiblaVibrationGuidance(bool value) {
    state = state.copyWith(qiblaVibrationGuidance: value);
    _storage.updateSettings(state);
  }

  void setFiqhMethod(FiqhMethod method) {
    state = state.copyWith(fiqhMethodIndex: method.index);
    _storage.updateSettings(state);
  }

  void setCalculationMethod(PrayerCalculationMethod method) {
    state = state.copyWith(calculationMethodIndex: method.index);
    _storage.updateSettings(state);
  }

  void setPrayerNotifications(bool value) {
    state = state.copyWith(prayerNotifications: value);
    _storage.updateSettings(state);
  }

  void setAdhanNotifications(bool value) {
    state = state.copyWith(adhanNotifications: value);
    _storage.updateSettings(state);
  }

  void setReduceMotion(bool value) {
    state = state.copyWith(reduceMotion: value);
    _storage.updateSettings(state);
  }

  void setLargeButtons(bool value) {
    state = state.copyWith(largeButtons: value);
    _storage.updateSettings(state);
  }

  void setScreenReaderOptimized(bool value) {
    state = state.copyWith(screenReaderOptimized: value);
    _storage.updateSettings(state);
  }

  void setSelectedZikrId(String? id) {
    state = state.copyWith(selectedZikrId: id);
    _storage.updateSettings(state);
  }

  void setLastLocation(String? cityName, double? lat, double? lng) {
    state = state.copyWith(
      lastCityName: cityName,
      lastLatitude: lat,
      lastLongitude: lng,
    );
    _storage.updateSettings(state);
  }
}

// Zikrs Provider
final zikrsProvider =
    StateNotifierProvider<ZikrsNotifier, List<ZikrModel>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ZikrsNotifier(storage);
});

class ZikrsNotifier extends StateNotifier<List<ZikrModel>> {
  final StorageService _storage;

  ZikrsNotifier(this._storage) : super(_storage.getAllZikrs());

  void refresh() {
    state = _storage.getAllZikrs();
  }

  Future<void> addZikr(ZikrModel zikr) async {
    await _storage.addZikr(zikr);
    state = _storage.getAllZikrs();
  }

  Future<void> updateZikr(ZikrModel zikr) async {
    await _storage.updateZikr(zikr);
    state = _storage.getAllZikrs();
  }

  Future<void> deleteZikr(String id) async {
    await _storage.deleteZikr(id);
    state = _storage.getAllZikrs();
  }

  Future<void> toggleFavorite(String id) async {
    final zikr = _storage.getZikr(id);
    if (zikr != null) {
      final updated = zikr.copyWith(isFavorite: !zikr.isFavorite);
      await _storage.updateZikr(updated);
      state = _storage.getAllZikrs();
    }
  }

  Future<void> reorderZikrs(int oldIndex, int newIndex) async {
    final items = List<ZikrModel>.from(state);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    await _storage.reorderZikrs(items);
    state = _storage.getAllZikrs();
  }

  List<ZikrModel> get favorites {
    return state.where((z) => z.isFavorite).toList();
  }

  List<ZikrModel> search(String query) {
    if (query.isEmpty) return state;
    final lowercaseQuery = query.toLowerCase();
    return state
        .where((z) =>
            z.name.toLowerCase().contains(lowercaseQuery) ||
            z.transliteration.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  ZikrModel? getSelectedZikr(String? zikrId) {
    if (zikrId == null) return state.isNotEmpty ? state.first : null;
    return _storage.getZikr(zikrId);
  }
}

// History Provider
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryModel>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return HistoryNotifier(storage);
});

class HistoryNotifier extends StateNotifier<List<HistoryModel>> {
  final StorageService _storage;

  HistoryNotifier(this._storage) : super(_storage.getAllHistory());

  void refresh() {
    state = _storage.getAllHistory();
  }

  Future<void> addHistory(HistoryModel history) async {
    await _storage.addHistory(history);
    state = _storage.getAllHistory();
  }

  Future<void> deleteHistory(String id) async {
    await _storage.deleteHistory(id);
    state = _storage.getAllHistory();
  }

  Future<void> clearAllHistory() async {
    await _storage.clearHistory();
    state = [];
  }

  List<HistoryModel> search(String query) {
    return _storage.searchHistory(query);
  }

  String exportCsv() {
    return _storage.exportHistoryToCsv();
  }
}

// Counter State Provider
class CounterState {
  final int count;
  final int? previousCount;
  final DateTime? startedAt;
  final bool targetReached;

  CounterState({
    this.count = 0,
    this.previousCount,
    this.startedAt,
    this.targetReached = false,
  });

  CounterState copyWith({
    int? count,
    int? previousCount,
    DateTime? startedAt,
    bool? targetReached,
  }) {
    return CounterState(
      count: count ?? this.count,
      previousCount: previousCount ?? this.previousCount,
      startedAt: startedAt ?? this.startedAt,
      targetReached: targetReached ?? this.targetReached,
    );
  }
}

final counterProvider =
    StateNotifierProvider<CounterNotifier, CounterState>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier() : super(CounterState());

  void increment({
    required int target,
    required VoiceAnnouncementMode mode,
    required bool voiceEnabled,
    required bool vibrationEnabled,
    required bool strongVibrationEnabled,
    required Function(String, int) onVoiceAnnounce,
    required Function(bool) onTargetReached,
    required Function() onVibrate,
    required Function() onStrongVibrate,
  }) {
    final newCount = state.count + 1;
    final targetReached = target > 0 && newCount >= target && target > state.count;

    state = state.copyWith(
      count: newCount,
      previousCount: state.count,
      startedAt: state.startedAt ?? DateTime.now(),
      targetReached: targetReached,
    );

    if (vibrationEnabled) {
      onVibrate();

      if (strongVibrationEnabled) {
        if (newCount == 33 || newCount == 99 || newCount == 100 || targetReached) {
          onStrongVibrate();
        }
      }
    }

    final shouldAnnounce = _shouldAnnounce(newCount, mode);
    if (voiceEnabled && shouldAnnounce) {
      onVoiceAnnounce('zikr', newCount);
    }

    if (targetReached) {
      onTargetReached(targetReached);
    }
  }

  bool _shouldAnnounce(int count, VoiceAnnouncementMode mode) {
    switch (mode) {
      case VoiceAnnouncementMode.everyCount:
        return true;
      case VoiceAnnouncementMode.every10:
        return count % 10 == 0;
      case VoiceAnnouncementMode.every33:
        return count % 33 == 0;
      case VoiceAnnouncementMode.every100:
        return count % 100 == 0;
      case VoiceAnnouncementMode.silent:
        return false;
    }
  }

  void reset() {
    state = CounterState(
      previousCount: state.count,
      startedAt: state.startedAt,
    );
  }

  void undoReset() {
    if (state.previousCount != null) {
      state = state.copyWith(
        count: state.previousCount!,
        previousCount: null,
        startedAt: state.startedAt,
      );
    }
  }

  void clearState() {
    state = CounterState();
  }
}

// Prayer Times Provider
final prayerTimesProvider = FutureProvider<DailyPrayerTimes?>((ref) async {
  final prayerService = ref.read(prayerTimeServiceProvider);
  final settings = ref.read(settingsProvider);

  await prayerService.initialize();

  return prayerService.calculatePrayerTimes(
    method: settings.calculationMethod,
    fiqh: settings.fiqhMethod,
  );
});

// Qibla Data Provider
// QiblaService.initialize() is called explicitly by QiblaScreen on mount and refresh.
// The stream is broadcast so late subscribers receive subsequent events.
final qiblaDataProvider = StreamProvider<QiblaData?>((ref) {
  final qiblaService = ref.read(qiblaServiceProvider);
  // Return null immediately while waiting; the screen calls initialize() which starts emitting
  return qiblaService.qiblaStream.cast<QiblaData?>();
});

// Selected Zikr Provider
final selectedZikrProvider = Provider<ZikrModel?>((ref) {
  final settings = ref.watch(settingsProvider);
  final zikrs = ref.watch(zikrsProvider);

  if (settings.selectedZikrId != null) {
    try {
      return zikrs.firstWhere((z) => z.id == settings.selectedZikrId);
    } catch (_) {}
  }

  return zikrs.isNotEmpty ? zikrs.first : null;
});
