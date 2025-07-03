import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'analog_clock_get.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const AlarmApp());
}

class AlarmApp extends StatelessWidget {
  const AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
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
  TimeOfDay? _selectedTime;

  late DateTime _currentTime;
  late final Ticker _ticker;

  // Multiple alarms support
  List<DateTime> _alarms = [];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

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

  Future<void> _addAlarm() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      var alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
      final millis = alarmTime.millisecondsSinceEpoch;
      try {
        await platform
            .invokeMethod('setAlarm', {'time': millis, 'alarmId': millis});
        setState(() {
          _alarms.add(alarmTime);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Alarm set for ${_formatTime(alarmTime)}')),
        );
      } on PlatformException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set alarm: ${e.message}')),
        );
      }
    }
  }

  void _deleteAlarm(int index) {
    setState(() {
      _alarms.removeAt(index);
    });
    // Note: For simplicity, this does not cancel the native alarm. Can be extended.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm App')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnalogClockGet(),
          const SizedBox(height: 24),
          Text(
            _formatTime(_currentTime),
            style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _addAlarm,
            child: const Text('Add Alarm'),
          ),
          const SizedBox(height: 40),
          Text('Scheduled Alarms:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: _alarms.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_formatTime(_alarms[index])),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAlarm(index),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Note: On some devices, only the system alarm app can show alarms over the lock screen. This is a device restriction, not a bug in this app. Your alarm will always play sound and show a notification.',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }
}
