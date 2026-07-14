import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Finance dashboard demo.
class FinanceDemoPage extends StatefulWidget {
  /// Creates the finance demo.
  const FinanceDemoPage({super.key});

  @override
  State<FinanceDemoPage> createState() => _FinanceDemoPageState();
}

class _FinanceDemoPageState extends State<FinanceDemoPage> {
  double _balance = 12840.55;
  double _dayChange = 1.8;

  Future<void> _push() async {
    await FlowWidget.saveBatch(
      entries: [
        FlowWidgetDataEntry(
          key: 'fin_balance',
          value: FlowWidgetValue.doubleValue(_balance),
        ),
        FlowWidgetDataEntry(
          key: 'fin_day_change',
          value: FlowWidgetValue.doubleValue(_dayChange),
        ),
      ],
    );
    await FlowWidget.update(name: 'FinanceWidget');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Finance',
      onPushToWidget: _push,
      children: [
        Text('Balance: \$${_balance.toStringAsFixed(2)}'),
        Slider(
          value: _balance,
          min: 1000,
          max: 50000,
          onChanged: (v) => setState(() => _balance = v),
        ),
        Text('Day change: ${_dayChange.toStringAsFixed(1)}%'),
        Slider(
          value: _dayChange,
          min: -5,
          max: 5,
          onChanged: (v) => setState(() => _dayChange = v),
        ),
      ],
    );
  }
}
