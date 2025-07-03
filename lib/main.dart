import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'model/alarm.dart';
import 'widgets/alarm_dialog.dart';
import 'widgets/alarm_tile.dart';
import 'widgets/digital_clock.dart';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AlarmAdapter());
  await Hive.openBox<Alarm>('alarms');
  await _requestNotificationPermission();
  runApp(const AlarmApp());
}

Future<void> _requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    final result = await Permission.notification.request();
    if (!result.isGranted) {
      // Show a user-facing dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Notification permission is required for alarms to work properly.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      });
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AlarmApp extends StatelessWidget {
  const AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      navigatorKey: navigatorKey,
      home: AlarmHomePage(),
    );
  }
}

class AlarmHomePage extends StatefulWidget {
  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  static const platform = MethodChannel('alarm_channel');
  late DateTime _currentTime;
  late final Ticker _ticker;
  late Box<Alarm> _alarmBox;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
    _alarmBox = Hive.box<Alarm>('alarms');
  }

  List<Alarm> get _alarms => _alarmBox.values.toList();

  void _onTick(Duration _) {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _showAlarmDialog({Alarm? alarm}) async {
    await showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        alarm: alarm,
        onSave: (newAlarm) async {
          debugPrint(
              'onSave called with alarm: ${newAlarm.id}, label: ${newAlarm.label}, enabled: ${newAlarm.enabled}');
          await _alarmBox.put(newAlarm.id.toString(), newAlarm);
          if (newAlarm.enabled) {
            await platform.invokeMethod('setAlarm', {
              'time': newAlarm.timeMillis,
              'alarmId': newAlarm.id,
              'vibration': newAlarm.vibration,
            });
          } else {
            // Optionally cancel native alarm here
          }
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _deleteAlarm(int index) async {
    final alarm = _alarms[index];
    try {
      await platform.invokeMethod('cancelAlarm', {'alarmId': alarm.id});
    } catch (e) {
      debugPrint('Error canceling alarm: $e');
    }
    await _alarmBox.delete(alarm.id.toString());
    setState(() {});
  }

  void _toggleAlarm(int index, bool value) async {
    final alarm = _alarms[index];
    final updated = Alarm(
      id: alarm.id,
      timeMillis: alarm.timeMillis,
      label: alarm.label,
      ringtone: alarm.ringtone,
      repeatDays: alarm.repeatDays,
      enabled: value,
    );
    await _alarmBox.put(alarm.id.toString(), updated);
    if (value) {
      await platform.invokeMethod('setAlarm', {
        'time': alarm.timeMillis,
        'alarmId': alarm.id,
        'vibration': alarm.vibration,
      });
    } else {
      try {
        await platform.invokeMethod('cancelAlarm', {'alarmId': alarm.id});
      } catch (e) {
        debugPrint('Error canceling alarm: $e');
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DigitalClock(time: _currentTime),
          const SizedBox(height: 40),
          Text('Scheduled Alarms:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) {
                final alarm = _alarms[index];
                return AlarmTile(
                  alarm: alarm,
                  onTap: () => _showAlarmDialog(alarm: alarm),
                  onToggle: (val) => _toggleAlarm(index, val),
                  onDelete: () => _deleteAlarm(index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (await Vibration.hasVibrator() ?? false) {
                Vibration.vibrate(duration: 1000);
              }
            },
            child: Text('Test Vibration'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlarmDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Alarm',
      ),
    );
  }

  String _formatTime(DateTime time) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }

  String _formatTimeWithSeconds(DateTime time) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }
}
