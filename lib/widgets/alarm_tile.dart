import 'package:flutter/material.dart';
import '../model/alarm.dart';

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const AlarmTile({
    Key? key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
          _formatTime(DateTime.fromMillisecondsSinceEpoch(alarm.timeMillis))),
      subtitle: Text('${alarm.label.isNotEmpty ? alarm.label : 'No label'}  '
          '${alarm.repeatDays.isNotEmpty ? 'Repeat: ' + alarm.repeatDays.map((d) => [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun'
              ][d - 1]).join(', ') : ''}'),
      leading: Switch(
        value: alarm.enabled,
        onChanged: onToggle,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
  }
}
