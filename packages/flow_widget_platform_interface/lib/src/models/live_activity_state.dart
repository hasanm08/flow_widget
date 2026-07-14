import '../types/flow_widget_value.dart';

/// Snapshot of an active Live Activity.
final class LiveActivityState {
  /// Creates a Live Activity state.
  const LiveActivityState({
    required this.activityId,
    required this.attributesType,
    required this.data,
    required this.startedAt,
    this.staleDate,
  });

  /// Platform activity identifier.
  final String activityId;

  /// ActivityAttributes type name.
  final String attributesType;

  /// Current content-state data.
  final Map<String, FlowWidgetValue> data;

  /// Start timestamp.
  final DateTime startedAt;

  /// Stale date, if set.
  final DateTime? staleDate;

  /// Wire decoding.
  factory LiveActivityState.fromWire(Map<Object?, Object?> wire) {
    final rawData = Map<Object?, Object?>.from(wire['data']! as Map);
    return LiveActivityState(
      activityId: wire['activityId']! as String,
      attributesType: wire['attributesType']! as String,
      data: {
        for (final e in rawData.entries)
          e.key! as String: FlowWidgetValue.fromWire(
            Map<Object?, Object?>.from(e.value! as Map),
          ),
      },
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        wire['startedAt']! as int,
        isUtc: true,
      ),
      staleDate: wire['staleDate'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              wire['staleDate']! as int,
              isUtc: true,
            ),
    );
  }
}
