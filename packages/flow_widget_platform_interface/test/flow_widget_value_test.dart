import 'package:flutter_test/flutter_test.dart';
import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

void main() {
  group('FlowWidgetValue', () {
    test('round-trips primitives through wire encoding', () {
      final cases = <FlowWidgetValue>[
        const FlowWidgetValue.string('hello'),
        const FlowWidgetValue.intValue(42),
        const FlowWidgetValue.doubleValue(3.14),
        const FlowWidgetValue.boolValue(true),
        FlowWidgetValue.dateTime(DateTime.utc(2026, 7, 14)),
        const FlowWidgetValue.json('{"a":1}'),
        FlowWidgetValue.map({'nested': const FlowWidgetValue.string('x')}),
        const FlowWidgetValue.list([
          FlowWidgetValue.intValue(1),
          FlowWidgetValue.intValue(2),
        ]),
      ];

      for (final value in cases) {
        final restored = FlowWidgetValue.fromWire(value.toWire());
        expect(restored, equals(value));
      }
    });

    test('box wraps Dart primitives', () {
      expect(FlowWidgetValue.box('a'), const FlowWidgetValue.string('a'));
      expect(FlowWidgetValue.box(1), const FlowWidgetValue.intValue(1));
      expect(FlowWidgetValue.box(true), const FlowWidgetValue.boolValue(true));
    });

    test('box rejects null', () {
      expect(() => FlowWidgetValue.box(null), throwsArgumentError);
    });
  });

  group('FlowWidgetId', () {
    test('equality and wire round-trip', () {
      const id = FlowWidgetId(name: 'Weather', id: 7);
      expect(FlowWidgetId.fromWire(id.toWire()), id);
      expect(id.targetsAllInstances, isFalse);
      expect(const FlowWidgetId(name: 'Weather').targetsAllInstances, isTrue);
    });
  });

  group('FlowWidgetCapabilities', () {
    test('fromWire reads flags', () {
      final caps = FlowWidgetCapabilities.fromWire({
        'homeWidgets': true,
        'liveActivities': true,
      });
      expect(caps.homeWidgets, isTrue);
      expect(caps.liveActivities, isTrue);
      expect(caps.wearTiles, isFalse);
    });
  });

  group('FlowWidgetEvent', () {
    test('parses click events', () {
      final event = FlowWidgetEvent.fromWire({
        'type': 'click',
        'timestamp': DateTime.utc(2026, 1, 1).millisecondsSinceEpoch,
        'widgetId': {'name': 'Checklist', 'id': 1},
        'action': 'toggle',
        'uri': 'flow://checklist/1',
      });
      expect(event, isA<FlowWidgetClickEvent>());
      final click = event as FlowWidgetClickEvent;
      expect(click.action, 'toggle');
      expect(click.uri.toString(), 'flow://checklist/1');
    });
  });
}
