import '../types/flow_widget_size.dart';
import 'flow_widget_family.dart';
import 'flow_widget_id.dart';

/// Runtime metadata for an installed widget instance.
final class FlowWidgetInfo {
  /// Creates widget info.
  const FlowWidgetInfo({
    required this.widgetId,
    required this.size,
    required this.family,
    this.lastUpdated,
  });

  /// Instance identifier.
  final FlowWidgetId widgetId;

  /// Current size class.
  final FlowWidgetSize size;

  /// Family.
  final FlowWidgetFamily family;

  /// Last update timestamp, if known.
  final DateTime? lastUpdated;

  /// Wire decoding.
  factory FlowWidgetInfo.fromWire(Map<Object?, Object?> wire) {
    return FlowWidgetInfo(
      widgetId: FlowWidgetId.fromWire(
        Map<Object?, Object?>.from(wire['widgetId']! as Map),
      ),
      size: FlowWidgetSize.values.byName(wire['size']! as String),
      family: FlowWidgetFamily.values.byName(wire['family']! as String),
      lastUpdated: wire['lastUpdated'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              wire['lastUpdated']! as int,
              isUtc: true,
            ),
    );
  }

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'widgetId': widgetId.toWire(),
    'size': size.name,
    'family': family.name,
    if (lastUpdated != null)
      'lastUpdated': lastUpdated!.toUtc().millisecondsSinceEpoch,
  };

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetInfo &&
      other.widgetId == widgetId &&
      other.size == size &&
      other.family == family;

  @override
  int get hashCode => Object.hash(widgetId, size, family);
}
