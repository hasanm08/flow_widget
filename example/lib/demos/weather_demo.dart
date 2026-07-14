import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Weather widget demo.
class WeatherDemoPage extends StatefulWidget {
  /// Creates the weather demo.
  const WeatherDemoPage({super.key});

  @override
  State<WeatherDemoPage> createState() => _WeatherDemoPageState();
}

class _WeatherDemoPageState extends State<WeatherDemoPage> {
  String _city = 'Toronto';
  double _temp = 22;
  String _condition = 'Partly cloudy';

  Future<void> _push() async {
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'weather_city',
          value: FlowWidgetValue.string(_city),
        ),
        FlowWidgetDataEntry(
          key: 'weather_temp',
          value: FlowWidgetValue.doubleValue(_temp),
        ),
        FlowWidgetDataEntry(
          key: 'weather_condition',
          value: FlowWidgetValue.string(_condition),
        ),
      ],
    );
    final now = DateTime.now().toUtc();
    await FlowWidget.setTimeline(
      name: 'WeatherWidget',
      entries: [
        for (var h = 0; h < 6; h++)
          FlowWidgetTimelineEntry(
            date: now.add(Duration(hours: h)),
            data: {
              'weather_city': FlowWidgetValue.string(_city),
              'weather_temp': FlowWidgetValue.doubleValue(_temp - h * 0.5),
              'weather_condition': FlowWidgetValue.string(_condition),
            },
            relevance: 1.0 - h * 0.1,
          ),
      ],
    );
    await FlowWidget.update(name: 'WeatherWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Weather',
      onPushToWidget: _push,
      children: [
        TextFormField(
          initialValue: _city,
          decoration: const InputDecoration(labelText: 'City'),
          onChanged: (v) => _city = v,
        ),
        const SizedBox(height: 16),
        Text('Temperature: ${_temp.toStringAsFixed(0)}°'),
        Slider(
          value: _temp,
          min: -20,
          max: 45,
          onChanged: (v) => setState(() => _temp = v),
        ),
        TextFormField(
          initialValue: _condition,
          decoration: const InputDecoration(labelText: 'Condition'),
          onChanged: (v) => _condition = v,
        ),
      ],
    );
  }
}
