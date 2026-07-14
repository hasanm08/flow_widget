import 'flow_widget_id.dart';
import '../types/flow_widget_value.dart';

/// Describes a single widget refresh request.
final class FlowWidgetUpdateRequest {
  /// Creates an update request for [name], optionally targeting one [id].
  const FlowWidgetUpdateRequest({
    required this.name,
    this.id,
    this.data,
    this.reloadTimeline = true,
  });

  /// Creates an update request from a [FlowWidgetId].
  factory FlowWidgetUpdateRequest.fromId(
    FlowWidgetId widgetId, {
    Map<String, FlowWidgetValue>? data,
    bool reloadTimeline = true,
  }) {
    return FlowWidgetUpdateRequest(
      name: widgetId.name,
      id: widgetId.id,
      data: data,
      reloadTimeline: reloadTimeline,
    );
  }

  /// Widget family name.
  final String name;

  /// Optional instance id.
  final int? id;

  /// Optional data to persist atomically before refreshing.
  final Map<String, FlowWidgetValue>? data;

  /// Whether the host should invalidate / reload the timeline.
  final bool reloadTimeline;

  /// Resolved identifier.
  FlowWidgetId get widgetId => FlowWidgetId(name: name, id: id);

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'name': name,
    if (id != null) 'id': id,
    'reloadTimeline': reloadTimeline,
    if (data != null)
      'data': <String, Object?>{
        for (final e in data!.entries) e.key: e.value.toWire(),
      },
  };
}
