import 'package:equatable/equatable.dart';

enum PrayerName {
  fajr('Fajr', 'فجر'),
  sunrise('Sunrise', 'طلوع'),
  dhuhr('Dhuhr', 'ظهر'),
  asr('Asr', 'عصر'),
  maghrib('Maghrib', 'مغرب'),
  isha('Isha', 'عشا');

  const PrayerName(this.english, this.arabic);
  final String english;
  final String arabic;
}

class PrayerTimeModel extends Equatable {
  final PrayerName name;
  final DateTime time;
  final bool isNext;

  const PrayerTimeModel({
    required this.name,
    required this.time,
    this.isNext = false,
  });

  PrayerTimeModel copyWith({
    PrayerName? name,
    DateTime? time,
    bool? isNext,
  }) {
    return PrayerTimeModel(
      name: name ?? this.name,
      time: time ?? this.time,
      isNext: isNext ?? this.isNext,
    );
  }

  Duration get timeUntil => time.difference(DateTime.now());

  String getFormattedTime() {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getTimeRemaining() {
    final remaining = timeUntil;
    if (remaining.isNegative) {
      return 'Past';
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  List<Object?> get props => [name, time, isNext];
}

class DailyPrayerTimes extends Equatable {
  final String? locationName;
  final double latitude;
  final double longitude;
  final DateTime date;
  final List<PrayerTimeModel> prayers;

  const DailyPrayerTimes({
    this.locationName,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.prayers,
  });

  PrayerTimeModel? get nextPrayer => prayers.where((p) => p.isNext).firstOrNull;

  String getFormattedDate() {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  @override
  List<Object?> get props => [locationName, latitude, longitude, date, prayers];
}
