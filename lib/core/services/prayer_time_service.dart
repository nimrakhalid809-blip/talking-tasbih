import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';

class PrayerTimeService {
  Position? _currentPosition;
  String? _locationName;
  bool _isInitialized = false;

  Position? get currentPosition => _currentPosition;
  String? get locationName => _locationName;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _determinePosition();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Prayer time initialization error: $e');
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  Future<DailyPrayerTimes> calculatePrayerTimes({
    required PrayerCalculationMethod method,
    required FiqhMethod fiqh,
    DateTime? date,
  }) async {
    if (_currentPosition == null) {
      await _determinePosition();
    }

    final targetDate = date ?? DateTime.now();
    final times = _calculatePrayerTimesInternal(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      date: targetDate,
      method: method,
      fiqh: fiqh,
    );

    return DailyPrayerTimes(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      date: targetDate,
      prayers: times,
    );
  }

  List<PrayerTimeModel> _calculatePrayerTimesInternal({
    required double latitude,
    required double longitude,
    required DateTime date,
    required PrayerCalculationMethod method,
    required FiqhMethod fiqh,
  }) {
    final params = _getMethodParams(method);
    final asrFactor = _getAsrFactor(fiqh);

    final prayerTimes = <PrayerTimeModel>[];
    final julianDate = _gregorianToJulian(date);

    // Calculate sun positions
    final decl = _sunDeclination(julianDate);
    final eqt = _equationOfTime(julianDate);

    final fajrAngle = params['fajr']!;
    final ishaAngle = params['isha']!;
    final maghribAdj = params['maghrib_adj'] ?? 0;
    final ishaAdj = params['isha_adj'];

    // Fajr
    final fajrTime = _computePrayerTime(
      latitude: latitude,
      declination: decl,
      eqnOfTime: eqt,
      angle: fajrAngle,
      isRising: true,
    );

    // Sunrise
    final sunriseTime = _computePrayerTime(
      latitude: latitude,
      declination: decl,
      eqnOfTime: eqt,
      angle: 0.833,
      isRising: true,
    );

    // Dhuhr
    final dhuhrTime = _toTime(12 - eqt / 60);

    // Asr (uses different calculation for Hanafi)
    final asrTime = _computeAsrTime(
      latitude: latitude,
      declination: decl,
      eqnOfTime: eqt,
      asrFactor: asrFactor,
    );

    // Maghrib
    final maghribTime = _computePrayerTime(
          latitude: latitude,
          declination: decl,
          eqnOfTime: eqt,
          angle: 0.833,
          isRising: false,
        ) +
        (maghribAdj / 60);

    // Isha
    double ishaTime;
    if (ishaAdj != null) {
      ishaTime = maghribTime + (ishaAdj / 60);
    } else {
      ishaTime = _computePrayerTime(
        latitude: latitude,
        declination: decl,
        eqnOfTime: eqt,
        angle: ishaAngle,
        isRising: false,
      );
    }

    final fajrDateTime = _timeToDateTime(date, fajrTime);
    final sunriseDateTime = _timeToDateTime(date, sunriseTime);
    final dhuhrDateTime = _timeToDateTime(date, dhuhrTime);
    final asrDateTime = _timeToDateTime(date, asrTime);
    final maghribDateTime = _timeToDateTime(date, maghribTime);
    final ishaDateTime = _timeToDateTime(date, ishaTime);

    final now = DateTime.now();
    final nextDateTime = _findNextPrayer(
      now,
      [fajrDateTime, sunriseDateTime, dhuhrDateTime, asrDateTime, maghribDateTime, ishaDateTime],
    );

    prayerTimes.addAll([
      PrayerTimeModel(name: PrayerName.fajr, time: fajrDateTime, isNext: fajrDateTime == nextDateTime),
      PrayerTimeModel(name: PrayerName.sunrise, time: sunriseDateTime, isNext: sunriseDateTime == nextDateTime),
      PrayerTimeModel(name: PrayerName.dhuhr, time: dhuhrDateTime, isNext: dhuhrDateTime == nextDateTime),
      PrayerTimeModel(name: PrayerName.asr, time: asrDateTime, isNext: asrDateTime == nextDateTime),
      PrayerTimeModel(name: PrayerName.maghrib, time: maghribDateTime, isNext: maghribDateTime == nextDateTime),
      PrayerTimeModel(name: PrayerName.isha, time: ishaDateTime, isNext: ishaDateTime == nextDateTime),
    ]);

    return prayerTimes;
  }

  DateTime _findNextPrayer(DateTime now, List<DateTime> prayerTimes) {
    for (final time in prayerTimes) {
      if (time.isAfter(now)) {
        return time;
      }
    }
    return prayerTimes.first;
  }

  Map<String, double> _getMethodParams(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.karachi:
        return {'fajr': 18.0, 'isha': 18.0};
      case PrayerCalculationMethod.muslimWorldLeague:
        return {'fajr': 18.0, 'isha': 17.0};
      case PrayerCalculationMethod.makkah:
        return {'fajr': 18.5, 'isha': 0, 'isha_adj': 90};
      case PrayerCalculationMethod.egyptian:
        return {'fajr': 19.5, 'isha': 17.5};
      case PrayerCalculationMethod.isna:
        return {'fajr': 15.0, 'isha': 15.0};
    }
  }

  double _getAsrFactor(FiqhMethod fiqh) {
    return fiqh == FiqhMethod.hanafi ? 2 : 1;
  }

  double _gregorianToJulian(DateTime date) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    int a = ((12 - month) / 12).floor();
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;

    return day + ((153 * m + 2) / 5).floor() + (365 * y) + (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
  }

  double _sunDeclination(double julianDate) {
    final d = julianDate - 2451545.0;
    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    final l = q + 1.915 * math.sin(_toRad(g)) + 0.020 * math.sin(_toRad(2 * g));
    final e = 23.439 - 0.00000036 * d;
    return _toDeg(math.asin(math.sin(_toRad(e)) * math.sin(_toRad(l))));
  }

  double _equationOfTime(double julianDate) {
    final d = julianDate - 2451545.0;
    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    return (q - 0.0057183 * d - d / 26000) - g - 1.915 * math.sin(_toRad(g)) - 0.020 * math.sin(_toRad(2 * g));
  }

  double _computePrayerTime({
    required double latitude,
    required double declination,
    required double eqnOfTime,
    required double angle,
    required bool isRising,
  }) {
    final latRad = _toRad(latitude);
    final declRad = _toRad(declination);
    final angleRad = _toRad(angle);

    final numerator = -math.sin(angleRad) - math.sin(latRad) * math.sin(declRad);
    final denominator = math.cos(latRad) * math.cos(declRad);
    final cosT = numerator / denominator;

    if (cosT.abs() > 1) {
      return isRising ? 0 : 12;
    }

    final t = _toDeg(math.acos(cosT)) / 15;
    return 12 - (eqnOfTime / 60) + (isRising ? -t : t);
  }

  double _computeAsrTime({
    required double latitude,
    required double declination,
    required double eqnOfTime,
    required double asrFactor,
  }) {
    final latRad = _toRad(latitude);
    final declRad = _toRad(declination);

    final a = math.atan(1 / (asrFactor + math.tan(latRad - declRad).abs()));
    final sinA = math.sin(a);
    final cosA = math.cos(a);

    final numerator = -sinA - math.sin(latRad) * math.sin(declRad);
    final denominator = math.cos(latRad) * math.cos(declRad);

    if ((numerator / denominator).abs() > 1) {
      return 12;
    }

    final t = _toDeg(math.acos(numerator / denominator)) / 15;
    return 12 - (eqnOfTime / 60) + t;
  }

  double _toTime(double hours) {
    return ((hours % 24) + 24) % 24;
  }

  DateTime _timeToDateTime(DateTime date, double time) {
    final hours = time.floor();
    final minutes = ((time - hours) * 60).floor();
    final seconds = (((time - hours) * 60 - minutes) * 60).floor();
    return DateTime(date.year, date.month, date.day, hours, minutes, seconds);
  }

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;

  String getPrayerNameLocalized(PrayerName prayer, AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return prayer.english;
      case AppLanguage.urdu:
        return _getUrduPrayerName(prayer);
      case AppLanguage.arabic:
        return prayer.arabic;
    }
  }

  String _getUrduPrayerName(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 'فجر';
      case PrayerName.sunrise:
        return 'طلوع آفتاب';
      case PrayerName.dhuhr:
        return 'ظہر';
      case PrayerName.asr:
        return 'عصر';
      case PrayerName.maghrib:
        return 'مغرب';
      case PrayerName.isha:
        return 'عشا';
    }
  }

  void dispose() {
    _isInitialized = false;
  }
}
