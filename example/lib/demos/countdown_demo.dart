import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Countdown demo with scheduled timeline entries.
class CountdownDemoPage extends StatefulWidget {
  /// Creates the countdown demo.
  const CountdownDemoPage({super.key});

  @override
  State<CountdownDemoPage> createState() => _CountdownDemoPageState();
}

class _CountdownDemoPageState extends State<CountdownDemoPage> {
  String _label = 'Launch day';
  DateTime _target = DateTime.now().add(const Duration(days: 14));

  Future<void> _push() async {
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'cd_label',
          value: FlowWidgetValue.string(_label),
        ),
        FlowWidgetDataEntry(
          key: 'cd_target',
          value: FlowWidgetValue.dateTime(_target),
        ),
      ],
    );
    final now = DateTime.now().toUtc();
    await FlowWidget.setTimeline(
      name: 'CountdownWidget',
      entries: [
        for (var d = 0; d < 7; d++)
          FlowWidgetTimelineEntry(
            date: now.add(Duration(days: d)),
            data: {
              'cd_label': FlowWidgetValue.string(_label),
              'cd_target': FlowWidgetValue.dateTime(_target),
              'cd_days_left': FlowWidgetValue.intValue(
                _target.difference(now.add(Duration(days: d))).inDays,
              ),
            },
          ),
      ],
    );
    await FlowWidget.update(name: 'CountdownWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Countdown',
      onPushToWidget: _push,
      children: [
        TextFormField(
          initialValue: _label,
          decoration: const InputDecoration(labelText: 'Label'),
          onChanged: (v) => _label = v,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Target'),
          subtitle: Text(_target.toLocal().toString().split('.').first),
          trailing: IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                initialDate: _target,
              );
              if (date != null) setState(() => _target = date);
            },
          ),
        ),
      ],
    );
  }
}
