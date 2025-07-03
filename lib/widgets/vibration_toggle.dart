import 'package:flutter/material.dart';

class VibrationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const VibrationToggle(
      {Key? key, required this.value, required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Vibration'),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
