import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class StorageService {
  static const String zikrsBoxName = 'zikrs';
  static const String historyBoxName = 'history';
  static const String settingsBoxName = 'settings';

  late Box<ZikrModel> _zikrsBox;
  late Box<HistoryModel> _historyBox;
  late Box<SettingsModel> _settingsBox;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);

    Hive.registerAdapter(ZikrModelAdapter());
    Hive.registerAdapter(HistoryModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());

    _zikrsBox = await Hive.openBox<ZikrModel>(zikrsBoxName);
    _historyBox = await Hive.openBox<HistoryModel>(historyBoxName);
    _settingsBox = await Hive.openBox<SettingsModel>(settingsBoxName);

    await _initializeDefaultData();
    _initialized = true;
  }

  Future<void> _initializeDefaultData() async {
    if (_zikrsBox.isEmpty) {
      final defaultZikrs = getDefaultZikrs();
      for (final zikr in defaultZikrs) {
        await _zikrsBox.put(zikr.id, zikr);
      }
    }

    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', SettingsModel());
    }
  }

  // Zikrs CRUD
  List<ZikrModel> getAllZikrs() {
    return _zikrsBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  ZikrModel? getZikr(String id) => _zikrsBox.get(id);

  Future<void> addZikr(ZikrModel zikr) async {
    await _zikrsBox.put(zikr.id, zikr);
  }

  Future<void> updateZikr(ZikrModel zikr) async {
    await _zikrsBox.put(zikr.id, zikr);
  }

  Future<void> deleteZikr(String id) async {
    final zikr = _zikrsBox.get(id);
    if (zikr != null && !zikr.isDefault) {
      await _zikrsBox.delete(id);
    }
  }

  Future<void> reorderZikrs(List<ZikrModel> zikrs) async {
    for (var i = 0; i < zikrs.length; i++) {
      final updated = zikrs[i].copyWith(sortOrder: i);
      await _zikrsBox.put(updated.id, updated);
    }
  }

  // History CRUD
  List<HistoryModel> getAllHistory() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  List<HistoryModel> searchHistory(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllHistory()
        .where((h) =>
            h.zikrName.toLowerCase().contains(lowercaseQuery) ||
            h.count.toString().contains(lowercaseQuery))
        .toList();
  }

  Future<void> addHistory(HistoryModel history) async {
    await _historyBox.add(history);
  }

  Future<void> deleteHistory(String id) async {
    await _historyBox.delete(id);
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  // Settings
  SettingsModel getSettings() {
    return _settingsBox.get('settings') ?? SettingsModel();
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _settingsBox.put('settings', settings);
  }

  // Export
  String exportHistoryToCsv() {
    final history = getAllHistory();
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Zikr,Count,Target,Completed,Duration');

    for (final h in history) {
      buffer.writeln(
          '${h.completedAt.toIso8601String()},${h.zikrName},${h.count},${h.target},${h.targetCompleted},${h.getFormattedDuration()}');
    }

    return buffer.toString();
  }
}
