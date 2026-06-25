import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../models/settings_model.dart';

class QiblaService {
  final StreamController<QiblaData> _qiblaController =
      StreamController<QiblaData>.broadcast();

  Stream<QiblaData> get qiblaStream => _qiblaController.stream;

  StreamSubscription<CompassEvent>? _compassSubscription;
  Position? _currentPosition;
  double? _kaabaDirection;
  bool _isInitialized = false;
  bool _compassAvailable = true;

  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  bool get isInitialized => _isInitialized;
  bool get compassAvailable => _compassAvailable;
  Position? get currentPosition => _currentPosition;
  double? get kaabaDirection => _kaabaDirection;

  Future<void> initialize() async {
    // Always reinitialize to allow refresh
    await _dispose();

    try {
      await _determinePosition();
      _calculateKaabaDirection();
      _startCompassListener();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Qibla initialization error: $e');
      rethrow;
    }
  }

  Future<void> _dispose() async {
    await _compassSubscription?.cancel();
    _compassSubscription = null;
    _isInitialized = false;
    // Do NOT close the broadcast controller — the StreamProvider holds a subscription to it.
    // Just cancel the compass subscription so the new one replaces it.
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
            'Location permission denied. Please grant location permission.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Please enable it in device settings.');
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  void _calculateKaabaDirection() {
    if (_currentPosition == null) return;

    _kaabaDirection = _calculateBearing(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      kaabaLatitude,
      kaabaLongitude,
    );
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final lonDiff = _degreesToRadians(lon2 - lon1);

    final y = math.sin(lonDiff) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(lonDiff);

    final bearing = math.atan2(y, x);
    return (_radiansToDegrees(bearing) + 360) % 360;
  }

  double _degreesToRadians(double degrees) => degrees * (math.pi / 180);
  double _radiansToDegrees(double radians) => radians * (180 / math.pi);

  void _startCompassListener() {
    if (FlutterCompass.events == null) {
      _compassAvailable = false;
      _qiblaController.addError(
        Exception(
          'Compass sensor is not available on this device. '
          'Please use a physical device with a magnetometer sensor.',
        ),
      );
      return;
    }

    _compassAvailable = true;
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events!.listen(
      (event) {
        final heading = event.heading;
        if (heading == null || _kaabaDirection == null) return;

        // Normalize heading to 0-360
        final normalizedHeading = (heading + 360) % 360;

        // qiblaOffset: how many degrees to rotate from current heading to face Qibla
        // Positive = clockwise (right), Negative = counter-clockwise (left)
        final qiblaOffset =
            (_kaabaDirection! - normalizedHeading + 360) % 360;

        // isAligned: within 3 degrees of Qibla in either direction
        final isAligned = qiblaOffset <= 3 || qiblaOffset >= 357;

        _qiblaController.add(QiblaData(
          heading: normalizedHeading,
          qiblaDirection: _kaabaDirection!,
          qiblaOffset: qiblaOffset,
          isAligned: isAligned,
          direction: _getDirection(qiblaOffset),
          accuracy: event.accuracy,
          needsCalibration:
              event.accuracy != null && event.accuracy! > 45,
        ));
      },
      onError: (error) {
        debugPrint('Compass stream error: $error');
        _qiblaController.addError(
          Exception('Compass sensor error: $error'),
        );
      },
    );
  }

  QiblaDirection _getDirection(double offset) {
    // offset is 0-360 clockwise from current heading to Qibla
    if (offset <= 3 || offset >= 357) {
      return QiblaDirection.perfect;
    } else if (offset > 3 && offset <= 15) {
      return QiblaDirection.turnSlightlyLeft;
    } else if (offset > 15 && offset < 90) {
      return QiblaDirection.turnLeft;
    } else if (offset >= 90 && offset <= 180) {
      return QiblaDirection.turnFarLeft;
    } else if (offset >= 181 && offset <= 270) {
      return QiblaDirection.turnFarRight;
    } else if (offset > 270 && offset < 345) {
      return QiblaDirection.turnRight;
    } else if (offset >= 345 && offset < 357) {
      return QiblaDirection.turnSlightlyRight;
    } else {
      return QiblaDirection.turnAround;
    }
  }

  Future<void> refreshPosition() async {
    try {
      await _determinePosition();
      _calculateKaabaDirection();
    } catch (e) {
      debugPrint('Refresh position error: $e');
      rethrow;
    }
  }

  String getVoiceGuidance(QiblaDirection direction, AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return _getEnglishGuidance(direction);
      case AppLanguage.urdu:
        return _getUrduGuidance(direction);
      case AppLanguage.arabic:
        return _getArabicGuidance(direction);
    }
  }

  String getCurrentHeadingAnnouncement(
      QiblaData data, AppLanguage language) {
    final heading = data.heading.toStringAsFixed(0);
    final qibla = data.qiblaDirection.toStringAsFixed(0);
    switch (language) {
      case AppLanguage.english:
        return 'Currently facing $heading degrees. Qibla is at $qibla degrees. '
            '${getVoiceGuidance(data.direction, language)}';
      case AppLanguage.urdu:
        return 'آپ اس وقت $heading ڈگری کی طرف ہیں۔ قبلہ $qibla ڈگری پر ہے۔ '
            '${getVoiceGuidance(data.direction, language)}';
      case AppLanguage.arabic:
        return 'أنت تواجه $heading درجة. القبلة في $qibla درجة. '
            '${getVoiceGuidance(data.direction, language)}';
    }
  }

  String _getEnglishGuidance(QiblaDirection direction) {
    switch (direction) {
      case QiblaDirection.perfect:
        return 'You are now facing the Qibla. Perfect alignment.';
      case QiblaDirection.turnSlightlyLeft:
        return 'Turn slightly left.';
      case QiblaDirection.turnLeft:
        return 'Turn left.';
      case QiblaDirection.turnFarLeft:
        return 'Turn far left.';
      case QiblaDirection.turnSlightlyRight:
        return 'Turn slightly right.';
      case QiblaDirection.turnRight:
        return 'Turn right.';
      case QiblaDirection.turnFarRight:
        return 'Turn far right.';
      case QiblaDirection.turnAround:
        return 'Turn around.';
    }
  }

  String _getUrduGuidance(QiblaDirection direction) {
    switch (direction) {
      case QiblaDirection.perfect:
        return 'آپ اب قبلہ کی طرف منہ کر رہے ہیں۔ بالکل ٹھیک۔';
      case QiblaDirection.turnSlightlyLeft:
        return 'تھوڑا بائیں مڑیں۔';
      case QiblaDirection.turnLeft:
        return 'بائیں مڑیں۔';
      case QiblaDirection.turnFarLeft:
        return 'زیادہ بائیں مڑیں۔';
      case QiblaDirection.turnSlightlyRight:
        return 'تھوڑا دائیں مڑیں۔';
      case QiblaDirection.turnRight:
        return 'دائیں مڑیں۔';
      case QiblaDirection.turnFarRight:
        return 'زیادہ دائیں مڑیں۔';
      case QiblaDirection.turnAround:
        return 'پیٹھ موڑ دیں۔';
    }
  }

  String _getArabicGuidance(QiblaDirection direction) {
    switch (direction) {
      case QiblaDirection.perfect:
        return 'أنت الآن متجه نحو القبلة. محاذاة مثالية.';
      case QiblaDirection.turnSlightlyLeft:
        return 'انعطف قليلاً إلى اليسار.';
      case QiblaDirection.turnLeft:
        return 'انعطف يساراً.';
      case QiblaDirection.turnFarLeft:
        return 'انعطف كثيراً يساراً.';
      case QiblaDirection.turnSlightlyRight:
        return 'انعطف قليلاً إلى اليمين.';
      case QiblaDirection.turnRight:
        return 'انعطف يميناً.';
      case QiblaDirection.turnFarRight:
        return 'انعطف كثيراً يميناً.';
      case QiblaDirection.turnAround:
        return 'استدر.';
    }
  }

  void dispose() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _qiblaController.close();
    _isInitialized = false;
  }
}

enum QiblaDirection {
  perfect,
  turnSlightlyLeft,
  turnLeft,
  turnFarLeft,
  turnSlightlyRight,
  turnRight,
  turnFarRight,
  turnAround,
}

class QiblaData {
  final double heading;
  final double qiblaDirection;
  final double qiblaOffset;
  final bool isAligned;
  final QiblaDirection direction;
  final double? accuracy;
  final bool needsCalibration;

  QiblaData({
    required this.heading,
    required this.qiblaDirection,
    required this.qiblaOffset,
    required this.isAligned,
    required this.direction,
    this.accuracy,
    this.needsCalibration = false,
  });
}
