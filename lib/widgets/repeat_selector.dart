import 'package:flutter/material.dart';

class RepeatSelector extends StatefulWidget {
  final List<int> initialDays;
  final ValueChanged<List<int>> onChanged;
  const RepeatSelector(
      {Key? key, required this.initialDays, required this.onChanged})
      : super(key: key);

  @override
  State<RepeatSelector> createState() => _RepeatSelectorState();
}

class _RepeatSelectorState extends State<RepeatSelector> {
  late List<int> selectedDays;

  static const List<int> weekdays = [1, 2, 3, 4, 5];
  static const List<int> weekends = [6, 7];
  static const List<int> everyday = [1, 2, 3, 4, 5, 6, 7];
  static const List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    selectedDays = List<int>.from(widget.initialDays);
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
      widget.onChanged(selectedDays..sort());
    });
  }

  void _setDays(List<int> days) {
    setState(() {
      selectedDays = List<int>.from(days);
      widget.onChanged(selectedDays..sort());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text('Repeat:'),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Never'),
                selected: selectedDays.isEmpty,
                onSelected: (_) => _setDays([]),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: Text('Everyday'),
                selected: selectedDays.length == 7,
                onSelected: (_) => _setDays(everyday),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: Text('Weekdays'),
                selected: selectedDays.length == 5 &&
                    selectedDays.every((d) => weekdays.contains(d)),
                onSelected: (_) => _setDays(weekdays),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: Text('Weekends'),
                selected: selectedDays.length == 2 &&
                    selectedDays.every((d) => weekends.contains(d)),
                onSelected: (_) => _setDays(weekends),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          children: List.generate(7, (i) {
            final day = i + 1;
            return ChoiceChip(
              label: Text(dayLabels[i]),
              selected: selectedDays.contains(day),
              onSelected: (_) => _toggleDay(day),
            );
          }),
        ),
      ],
    );
  }
}
