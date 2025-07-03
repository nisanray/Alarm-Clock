import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  int timeMillis;
  @HiveField(2)
  String label;
  @HiveField(3)
  String ringtone;
  @HiveField(4)
  List<int> repeatDays; // 1=Mon, 7=Sun
  @HiveField(5)
  bool enabled;
  @HiveField(6)
  bool vibration;

  Alarm({
    required this.id,
    required this.timeMillis,
    this.label = '',
    this.ringtone = '',
    this.repeatDays = const [],
    this.enabled = true,
    this.vibration = true,
  });
}
