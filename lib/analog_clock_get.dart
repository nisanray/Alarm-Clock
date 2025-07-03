import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClockController extends GetxController {
  Rx<DateTime> now = DateTime.now().obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now.value = DateTime.now();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class AnalogClockGet extends StatelessWidget {
  AnalogClockGet({Key? key}) : super(key: key);
  final ClockController controller = Get.put(ClockController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFE3F0FF), Color(0xFFB6D0E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _AnalogClockPainter(controller.now.value),
          ),
        ));
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime now;
  _AnalogClockPainter(this.now);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Draw background circle with shadow
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.blue[50]!, Colors.blue[100]!],
        stops: const [0.7, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.blueGrey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw hour ticks
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final isQuarter = i % 3 == 0;
      final tickLength = isQuarter ? 18.0 : 10.0;
      final tickWidth = isQuarter ? 5.0 : 2.5;
      final tickColor =
          isQuarter ? Colors.blueGrey.shade700 : Colors.blueGrey.shade400;
      final paint = Paint()
        ..color = tickColor
        ..strokeWidth = tickWidth
        ..strokeCap = StrokeCap.round;
      final start = Offset(
        center.dx + (radius - tickLength) * sin(angle),
        center.dy - (radius - tickLength) * cos(angle),
      );
      final end = Offset(
        center.dx + radius * sin(angle),
        center.dy - radius * cos(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw numbers with elegant font
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final offset = Offset(
        center.dx + (radius - 36) * cos(angle),
        center.dy + (radius - 36) * sin(angle),
      );
      textPainter.text = TextSpan(
        text: '$i',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey.shade800,
          fontFamily: 'Arial',
        ),
      );
      textPainter.layout();
      final textOffset =
          offset - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
    }

    // Draw hour hand
    final hourAngle = ((now.hour % 12) + now.minute / 60) * 30 * pi / 180;
    final hourHandLength = radius * 0.48;
    final hourHand = Offset(
      center.dx + hourHandLength * sin(hourAngle),
      center.dy - hourHandLength * cos(hourAngle),
    );
    canvas.drawLine(
        center,
        hourHand,
        Paint()
          ..color = Colors.blueGrey.shade900
          ..strokeWidth = 8
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
          ..color = Colors.blue.shade400
          ..strokeWidth = 5
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
          ..color = Colors.redAccent
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    // Draw center dot with highlight
    final centerDotPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.blueGrey.shade700],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 10));
    canvas.drawCircle(center, 10, centerDotPaint);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.now.minute != now.minute ||
        oldDelegate.now.hour != now.hour;
  }
}
