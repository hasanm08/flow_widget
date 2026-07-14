import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Live Activity / Dynamic Island demo.
class LiveActivityDemoPage extends StatefulWidget {
  /// Creates the Live Activity demo.
  const LiveActivityDemoPage({super.key});

  @override
  State<LiveActivityDemoPage> createState() => _LiveActivityDemoPageState();
}

class _LiveActivityDemoPageState extends State<LiveActivityDemoPage> {
  String? _activityId;
  String _status = 'Preparing order';
  int _etaMinutes = 25;

  Future<void> _start() async {
    try {
      final id = await FlowWidget.liveActivity.start(
        LiveActivityConfig(
          attributesType: 'DeliveryAttributes',
          data: {
            'status': FlowWidgetValue.string(_status),
            'etaMinutes': FlowWidgetValue.intValue(_etaMinutes),
          },
          staleDate: DateTime.now().toUtc().add(const Duration(hours: 2)),
        ),
      );
      setState(() => _activityId = id);
    } on FlowWidgetException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _update() async {
    final id = _activityId;
    if (id == null) return;
    await FlowWidget.liveActivity.update(
      activityId: id,
      data: {'status': _status, 'etaMinutes': _etaMinutes},
    );
  }

  Future<void> _end() async {
    final id = _activityId;
    if (id == null) return;
    await FlowWidget.liveActivity.end(
      activityId: id,
      finalData: {'status': 'Delivered'},
    );
    setState(() => _activityId = null);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Live Activities',
      onPushToWidget: _activityId == null ? _start : _update,
      secondaryAction: _activityId == null
          ? null
          : OutlinedButton.icon(
              onPressed: _end,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('End activity'),
            ),
      children: [
        Text(
          _activityId == null
              ? 'No active Live Activity'
              : 'Active: $_activityId',
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _status,
          decoration: const InputDecoration(labelText: 'Status'),
          onChanged: (v) => _status = v,
        ),
        Text('ETA: $_etaMinutes min'),
        Slider(
          value: _etaMinutes.toDouble(),
          min: 1,
          max: 90,
          divisions: 89,
          onChanged: (v) => setState(() => _etaMinutes = v.round()),
        ),
      ],
    );
  }
}
