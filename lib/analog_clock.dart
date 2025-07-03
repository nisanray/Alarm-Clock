import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnalogClock extends StatefulWidget {
  const AnalogClock({Key? key}) : super(key: key);

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: _AnalogClockPainter(_now),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime now;
  _AnalogClockPainter(this.now);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final tickPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    final hourTickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    final outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw clock face
    canvas.drawCircle(center, radius, outlinePaint);

    // Draw hour ticks
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final length = i % 3 == 0 ? 16.0 : 8.0;
      final paint = i % 3 == 0 ? hourTickPaint : tickPaint;
      final start = Offset(
        center.dx + (radius - length) * sin(angle),
        center.dy - (radius - length) * cos(angle),
      );
      final end = Offset(
        center.dx + radius * sin(angle),
        center.dy - radius * cos(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw numbers
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final offset = Offset(
        center.dx + (radius - 32) * cos(angle),
        center.dy + (radius - 32) * sin(angle),
      );
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(fontSize: 18, color: Colors.black),
      );
      textPainter.layout();
      final textOffset =
          offset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }

    // Draw hour hand
    final hourAngle = ((now.hour % 12) + now.minute / 60) * 30 * pi / 180;
    final hourHandLength = radius * 0.5;
    final hourHand = Offset(
      center.dx + hourHandLength * sin(hourAngle),
      center.dy - hourHandLength * cos(hourAngle),
    );
    canvas.drawLine(
        center,
        hourHand,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);

    // Draw minute hand
    final minuteAngle = (now.minute + now.second / 60) * 6 * pi / 180;
    final minuteHandLength = radius * 0.7;
    final minuteHand = Offset(
      center.dx + minuteHandLength * sin(minuteAngle),
      center.dy - minuteHandLength * cos(minuteAngle),
    );
    canvas.drawLine(
        center,
        minuteHand,
        Paint()
          ..color = Colors.blueGrey
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round);

    // Draw second hand
    final secondAngle = now.second * 6 * pi / 180;
    final secondHandLength = radius * 0.85;
    final secondHand = Offset(
      center.dx + secondHandLength * sin(secondAngle),
      center.dy - secondHandLength * cos(secondAngle),
    );
    canvas.drawLine(
        center,
        secondHand,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);

    // Draw center dot
    canvas.drawCircle(center, 6, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.now.minute != now.minute ||
        oldDelegate.now.hour != now.hour;
  }
}
