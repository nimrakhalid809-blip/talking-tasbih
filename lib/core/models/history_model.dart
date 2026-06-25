import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 1)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String zikrId;

  @HiveField(2)
  final String zikrName;

  @HiveField(3)
  final int count;

  @HiveField(4)
  final int target;

  @HiveField(5)
  final bool targetCompleted;

  @HiveField(6)
  final DateTime startedAt;

  @HiveField(7)
  final DateTime completedAt;

  HistoryModel({
    required this.id,
    required this.zikrId,
    required this.zikrName,
    required this.count,
    this.target = 0,
    this.targetCompleted = false,
    required this.startedAt,
    required this.completedAt,
  });

  Duration get duration => completedAt.difference(startedAt);

  String getFormattedDuration() {
    final duration = this.duration;
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    }
    return '${duration.inSeconds}s';
  }
}
