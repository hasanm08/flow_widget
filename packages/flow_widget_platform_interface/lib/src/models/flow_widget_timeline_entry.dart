import '../types/flow_widget_value.dart';

/// A single point on a widget timeline (WidgetKit / Glance).
final class FlowWidgetTimelineEntry {
  /// Creates a timeline entry that becomes active at [date].
  const FlowWidgetTimelineEntry({
    required this.date,
    required this.data,
    this.relevance,
  });

  /// Instant when this entry becomes the current snapshot.
  final DateTime date;

  /// Snapshot data for the widget renderer.
  final Map<String, FlowWidgetValue> data;

  /// Optional relevance score for Smart Stack (0.0 – 1.0).
  final double? relevance;

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'date': date.toUtc().millisecondsSinceEpoch,
    'data': <String, Object?>{
      for (final e in data.entries) e.key: e.value.toWire(),
    },
    if (relevance != null) 'relevance': relevance,
  };

  /// Wire decoding.
  factory FlowWidgetTimelineEntry.fromWire(Map<Object?, Object?> wire) {
    final rawData = Map<Object?, Object?>.from(wire['data']! as Map);
    return FlowWidgetTimelineEntry(
      date: DateTime.fromMillisecondsSinceEpoch(
        wire['date']! as int,
        isUtc: true,
      ),
      data: {
        for (final e in rawData.entries)
          e.key! as String: FlowWidgetValue.fromWire(
            Map<Object?, Object?>.from(e.value! as Map),
          ),
      },
      relevance: (wire['relevance'] as num?)?.toDouble(),
    );
  }
}
