import 'package:flutter/material.dart';
import '../model/alarm.dart';
import 'repeat_selector.dart';
import 'vibration_toggle.dart';

class AlarmDialog extends StatefulWidget {
  final Alarm? alarm;
  final void Function(Alarm) onSave;

  const AlarmDialog({Key? key, this.alarm, required this.onSave})
      : super(key: key);

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  late DateTime selectedTime;
  late TextEditingController labelController;
  late String ringtone;
  late List<int> repeatDays;
  late bool enabled;
  late bool vibration;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.alarm != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.alarm!.timeMillis)
        : DateTime.now().add(const Duration(minutes: 1));
    labelController = TextEditingController(text: widget.alarm?.label ?? '');
    ringtone = widget.alarm?.ringtone ?? 'old_alarm.mp3';
    repeatDays = List<int>.from(widget.alarm?.repeatDays ?? []);
    enabled = widget.alarm?.enabled ?? true;
    vibration = widget.alarm?.vibration ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.alarm != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Alarm' : 'Add Alarm'),
      content: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Time: ${_formatTime(selectedTime)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedTime),
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = DateTime(
                      selectedTime.year,
                      selectedTime.month,
                      selectedTime.day,
                      picked.hour,
                      picked.minute,
                    );
                  });
                }
              },
            ),
            TextField(
              controller: labelController,
              decoration: InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: ringtone,
              items: [
                DropdownMenuItem(
                  value: 'old_alarm.mp3',
                  child: Text('Default (old_alarm.mp3)'),
                ),
                // Add more ringtones here if needed
              ],
              onChanged: (val) {
                setState(() {
                  ringtone = val ?? 'old_alarm.mp3';
                });
              },
              decoration: InputDecoration(labelText: 'Ringtone'),
            ),
            const SizedBox(height: 8),
            RepeatSelector(
              initialDays: repeatDays,
              onChanged: (days) {
                setState(() {
                  repeatDays = days;
                });
              },
            ),
            const SizedBox(height: 8),
            VibrationToggle(
              value: vibration,
              onChanged: (val) {
                setState(() {
                  vibration = val;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enabled'),
                Switch(
                  value: enabled,
                  onChanged: (val) {
                    setState(() {
                      enabled = val;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final millis = DateTime(
              selectedTime.year,
              selectedTime.month,
              selectedTime.day,
              selectedTime.hour,
              selectedTime.minute,
            ).millisecondsSinceEpoch;
            final alarmId = isEdit ? widget.alarm!.id : millis;
            final newAlarm = Alarm(
              id: alarmId,
              timeMillis: millis,
              label: labelController.text,
              ringtone: ringtone,
              repeatDays: repeatDays,
              enabled: enabled,
              vibration: vibration,
            );
            debugPrint(
                'Saving alarm: id=$alarmId, time=$millis, label=${labelController.text}, enabled=$enabled');
            widget.onSave(newAlarm);
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }
}
