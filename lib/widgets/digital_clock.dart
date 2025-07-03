import 'package:flutter/material.dart';

class DigitalClock extends StatelessWidget {
  final DateTime time;
  const DigitalClock({Key? key, required this.time}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDate(time),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Text(
              _formatTimeWithSeconds(time),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 4,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeWithSeconds(DateTime time) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }

  String _formatDate(DateTime time) {
    // Example: Monday, 24 June 2024
    final weekdays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    final weekday = weekdays[time.weekday - 1];
    final month = months[time.month - 1];
    return '$weekday, ${time.day} $month ${time.year}';
  }
}
