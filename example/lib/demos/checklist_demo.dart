import 'package:flutter/material.dart';
import 'package:flow_widget/flow_widget.dart';

import 'demo_scaffold.dart';

/// Interactive checklist with multiple instance support.
class ChecklistDemoPage extends StatefulWidget {
  /// Creates the checklist demo.
  const ChecklistDemoPage({super.key});

  @override
  State<ChecklistDemoPage> createState() => _ChecklistDemoPageState();
}

class _ChecklistDemoPageState extends State<ChecklistDemoPage> {
  final List<_Item> _items = [
    const _Item(id: '1', title: 'Buy milk', done: false),
    const _Item(id: '2', title: 'Ship PR', done: true),
    const _Item(id: '3', title: 'Walk dog', done: false),
  ];
  int _instanceId = 1;

  Future<void> _push() async {
    await FlowWidget.saveData(
      key: 'checklist_$_instanceId',
      value: <String, Object?>{
        for (final item in _items)
          item.id: <String, Object?>{'title': item.title, 'done': item.done},
      },
    );
    await FlowWidget.update(name: 'ChecklistWidget', id: _instanceId);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Checklist',
      onPushToWidget: _push,
      secondaryAction: OutlinedButton.icon(
        onPressed: () async {
          final pinned = await FlowWidget.requestPinWidget(
            name: 'ChecklistWidget',
            initialData: {'instance': _instanceId},
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  pinned ? 'Pin request accepted' : 'Pin not available',
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.push_pin_outlined),
        label: const Text('Request pin widget'),
      ),
      children: [
        Row(
          children: [
            const Text('Instance id'),
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: _instanceId,
              items: [
                for (var i = 1; i <= 3; i++)
                  DropdownMenuItem(value: i, child: Text('#$i')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _instanceId = v);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < _items.length; i++)
          CheckboxListTile(
            value: _items[i].done,
            title: Text(_items[i].title),
            onChanged: (v) {
              setState(() {
                _items[i] = _items[i].copyWith(done: v ?? false);
              });
            },
          ),
      ],
    );
  }
}

final class _Item {
  const _Item({required this.id, required this.title, required this.done});

  final String id;
  final String title;
  final bool done;

  _Item copyWith({bool? done}) =>
      _Item(id: id, title: title, done: done ?? this.done);
}
