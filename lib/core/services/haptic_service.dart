import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class HapticService {
  bool _isAvailable = false;
  bool _isInitialized = false;

  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isAvailable = await Vibration.hasVibrator() ?? false;
    } catch (e) {
      debugPrint('Haptic initialization error: $e');
      _isAvailable = false;
    }

    _isInitialized = true;
  }

  Future<void> lightTap() async {
    if (!_isAvailable) return;

    try {
      await Vibration.vibrate(duration: 10);
    } catch (e) {
      debugPrint('Light vibration error: $e');
    }
  }

  Future<void> mediumTap() async {
    if (!_isAvailable) return;

    try {
      await Vibration.vibrate(duration: 25);
    } catch (e) {
      debugPrint('Medium vibration error: $e');
    }
  }

  Future<void> strongVibration() async {
    if (!_isAvailable) return;

    try {
      await Vibration.vibrate(duration: 100);
    } catch (e) {
      debugPrint('Strong vibration error: $e');
    }
  }

  Future<void> targetComplete() async {
    if (!_isAvailable) return;

    try {
      // Pattern: wait, vibrate, wait, vibrate
      await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
    } catch (e) {
      debugPrint('Target complete vibration error: $e');
    }
  }

  Future<void> qiblaAligned() async {
    if (!_isAvailable) return;

    try {
      await Vibration.vibrate(pattern: [0, 50, 100, 50, 100, 50]);
    } catch (e) {
      debugPrint('Qibla alignment vibration error: $e');
    }
  }

  Future<void> warning() async {
    if (!_isAvailable) return;

    try {
      await Vibration.vibrate(pattern: [0, 200, 100, 200]);
    } catch (e) {
      debugPrint('Warning vibration error: $e');
    }
  }

  Future<void> success() async {
    if (!_isAvailable) return;

    try {
      await Vibration.vibrate(duration: 150);
    } catch (e) {
      debugPrint('Success vibration error: $e');
    }
  }

  void dispose() {
    _isInitialized = false;
  }
}
