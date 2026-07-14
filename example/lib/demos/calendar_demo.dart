import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Calendar next-events demo.
class CalendarDemoPage extends StatefulWidget {
  /// Creates the calendar demo.
  const CalendarDemoPage({super.key});

  @override
  State<CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<CalendarDemoPage> {
  String _nextEvent = 'Design review';
  DateTime _when = DateTime.now().add(const Duration(hours: 2));

  Future<void> _push() async {
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'cal_title',
          value: FlowWidgetValue.string(_nextEvent),
        ),
        FlowWidgetDataEntry(
          key: 'cal_when',
          value: FlowWidgetValue.dateTime(_when),
        ),
      ],
    );
    await FlowWidget.update(name: 'CalendarWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Calendar',
      onPushToWidget: _push,
      children: [
        TextFormField(
          initialValue: _nextEvent,
          decoration: const InputDecoration(labelText: 'Next event'),
          onChanged: (v) => _nextEvent = v,
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Starts'),
          subtitle: Text(_when.toLocal().toString()),
          trailing: IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: _when,
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_when),
              );
              if (time == null) return;
              setState(() {
                _when = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
