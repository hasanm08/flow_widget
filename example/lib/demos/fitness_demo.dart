import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Fitness rings demo.
class FitnessDemoPage extends StatefulWidget {
  /// Creates the fitness demo.
  const FitnessDemoPage({super.key});

  @override
  State<FitnessDemoPage> createState() => _FitnessDemoPageState();
}

class _FitnessDemoPageState extends State<FitnessDemoPage> {
  double _move = 420;
  double _exercise = 28;
  double _stand = 10;

  Future<void> _push() async {
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'fit_move',
          value: FlowWidgetValue.doubleValue(_move),
        ),
        FlowWidgetDataEntry(
          key: 'fit_exercise',
          value: FlowWidgetValue.doubleValue(_exercise),
        ),
        FlowWidgetDataEntry(
          key: 'fit_stand',
          value: FlowWidgetValue.doubleValue(_stand),
        ),
      ],
    );
    await FlowWidget.update(name: 'FitnessWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Fitness',
      onPushToWidget: _push,
      children: [
        Text('Move: ${_move.toStringAsFixed(0)} kcal'),
        Slider(
          value: _move,
          max: 800,
          onChanged: (v) => setState(() => _move = v),
        ),
        Text('Exercise: ${_exercise.toStringAsFixed(0)} min'),
        Slider(
          value: _exercise,
          max: 60,
          onChanged: (v) => setState(() => _exercise = v),
        ),
        Text('Stand: ${_stand.toStringAsFixed(0)} hrs'),
        Slider(
          value: _stand,
          max: 12,
          onChanged: (v) => setState(() => _stand = v),
        ),
      ],
    );
  }
}
