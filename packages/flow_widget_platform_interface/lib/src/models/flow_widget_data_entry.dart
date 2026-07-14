import '../types/flow_widget_value.dart';

/// A single key/value pair for batched shared-storage writes.
final class FlowWidgetDataEntry {
  /// Creates a data entry.
  const FlowWidgetDataEntry({required this.key, required this.value});

  /// Storage key.
  final String key;

  /// Typed value.
  final FlowWidgetValue value;

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'key': key,
    'value': value.toWire(),
  };

  /// Wire decoding.
  factory FlowWidgetDataEntry.fromWire(Map<Object?, Object?> wire) {
    return FlowWidgetDataEntry(
      key: wire['key']! as String,
      value: FlowWidgetValue.fromWire(
        Map<Object?, Object?>.from(wire['value']! as Map),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetDataEntry && other.key == key && other.value == value;

  @override
  int get hashCode => Object.hash(key, value);
}
