import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Habit tracker demo with interactive toggles.
class HabitDemoPage extends StatefulWidget {
  /// Creates the habit demo.
  const HabitDemoPage({super.key});

  @override
  State<HabitDemoPage> createState() => _HabitDemoPageState();
}

class _HabitDemoPageState extends State<HabitDemoPage> {
  final Map<String, bool> _habits = {
    'Meditate': true,
    'Read': false,
    'Exercise': true,
    'Journal': false,
  };

  Future<void> _push() async {
    await FlowWidget.saveData(
      key: 'habits_json',
      value: {for (final e in _habits.entries) e.key: e.value},
    );
    await FlowWidget.update(name: 'HabitWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Habit Tracker',
      onPushToWidget: _push,
      children: [
        for (final e in _habits.entries)
          SwitchListTile(
            title: Text(e.key),
            value: e.value,
            onChanged: (v) => setState(() => _habits[e.key] = v),
          ),
      ],
    );
  }
}
