import '../models/flow_widget_id.dart';
import '../types/flow_widget_value.dart';

/// Base type for all events emitted by the flow_widget platform channel.
sealed class FlowWidgetEvent {
  /// Creates a platform event.
  const FlowWidgetEvent({required this.timestamp});

  /// Instant the event was observed (UTC).
  final DateTime timestamp;

  /// Parses a wire-encoded event map.
  static FlowWidgetEvent fromWire(Map<Object?, Object?> wire) {
    final type = wire['type'] as String?;
    final ts = DateTime.fromMillisecondsSinceEpoch(
      wire['timestamp'] as int? ?? DateTime.now().toUtc().millisecondsSinceEpoch,
      isUtc: true,
    );
    return switch (type) {
      'click' => FlowWidgetClickEvent.fromWire(wire, timestamp: ts),
      'configured' => FlowWidgetConfiguredEvent.fromWire(wire, timestamp: ts),
      'timeline' => FlowWidgetTimelineReloadEvent.fromWire(wire, timestamp: ts),
      'liveActivity' =>
        FlowWidgetLiveActivityEvent.fromWire(wire, timestamp: ts),
      _ => FlowWidgetUnknownEvent(rawType: type ?? 'unknown', timestamp: ts),
    };
  }
}

/// Emitted when the user interacts with a widget (tap, button, toggle).
final class FlowWidgetClickEvent extends FlowWidgetEvent {
  /// Creates a click event.
  const FlowWidgetClickEvent({
    required this.widgetId,
    required super.timestamp,
    this.action,
    this.payload = const {},
    this.uri,
  });

  /// Widget that received the interaction.
  final FlowWidgetId widgetId;

  /// Named action (e.g. `"toggleHabit"`, `"playPause"`).
  final String? action;

  /// Optional action payload.
  final Map<String, FlowWidgetValue> payload;

  /// Optional deep-link URI associated with the click.
  final Uri? uri;

  /// Wire decoding.
  factory FlowWidgetClickEvent.fromWire(
    Map<Object?, Object?> wire, {
    required DateTime timestamp,
  }) {
    final rawPayload = wire['payload'] == null
        ? <String, FlowWidgetValue>{}
        : {
            for (final e
                in Map<Object?, Object?>.from(wire['payload']! as Map).entries)
              e.key! as String: FlowWidgetValue.fromWire(
                Map<Object?, Object?>.from(e.value! as Map),
              ),
          };
    final uriString = wire['uri'] as String?;
    return FlowWidgetClickEvent(
      widgetId: FlowWidgetId.fromWire(
        Map<Object?, Object?>.from(wire['widgetId']! as Map),
      ),
      action: wire['action'] as String?,
      payload: rawPayload,
      uri: uriString == null ? null : Uri.tryParse(uriString),
      timestamp: timestamp,
    );
  }

  @override
  String toString() =>
      'FlowWidgetClickEvent(widgetId: $widgetId, action: $action, uri: $uri)';
}

/// Emitted when the user finishes configuring a widget.
final class FlowWidgetConfiguredEvent extends FlowWidgetEvent {
  /// Creates a configured event.
  const FlowWidgetConfiguredEvent({
    required this.widgetId,
    required this.data,
    required super.timestamp,
  });

  /// Configured widget.
  final FlowWidgetId widgetId;

  /// Configuration values chosen by the user.
  final Map<String, FlowWidgetValue> data;

  /// Wire decoding.
  factory FlowWidgetConfiguredEvent.fromWire(
    Map<Object?, Object?> wire, {
    required DateTime timestamp,
  }) {
    final rawData = wire['data'] == null
        ? <String, FlowWidgetValue>{}
        : {
            for (final e
                in Map<Object?, Object?>.from(wire['data']! as Map).entries)
              e.key! as String: FlowWidgetValue.fromWire(
                Map<Object?, Object?>.from(e.value! as Map),
              ),
          };
    return FlowWidgetConfiguredEvent(
      widgetId: FlowWidgetId.fromWire(
        Map<Object?, Object?>.from(wire['widgetId']! as Map),
      ),
      data: rawData,
      timestamp: timestamp,
    );
  }
}

/// Emitted when the host asks the app to reload a timeline.
final class FlowWidgetTimelineReloadEvent extends FlowWidgetEvent {
  /// Creates a timeline reload event.
  const FlowWidgetTimelineReloadEvent({
    required this.widgetId,
    required super.timestamp,
  });

  /// Widget whose timeline should be rebuilt.
  final FlowWidgetId widgetId;

  /// Wire decoding.
  factory FlowWidgetTimelineReloadEvent.fromWire(
    Map<Object?, Object?> wire, {
    required DateTime timestamp,
  }) {
    return FlowWidgetTimelineReloadEvent(
      widgetId: FlowWidgetId.fromWire(
        Map<Object?, Object?>.from(wire['widgetId']! as Map),
      ),
      timestamp: timestamp,
    );
  }
}

/// Emitted when a Live Activity changes state.
final class FlowWidgetLiveActivityEvent extends FlowWidgetEvent {
  /// Creates a Live Activity event.
  const FlowWidgetLiveActivityEvent({
    required this.activityId,
    required this.phase,
    required super.timestamp,
  });

  /// Activity id.
  final String activityId;

  /// Lifecycle phase.
  final LiveActivityPhase phase;

  /// Wire decoding.
  factory FlowWidgetLiveActivityEvent.fromWire(
    Map<Object?, Object?> wire, {
    required DateTime timestamp,
  }) {
    return FlowWidgetLiveActivityEvent(
      activityId: wire['activityId']! as String,
      phase: LiveActivityPhase.values.byName(wire['phase']! as String),
      timestamp: timestamp,
    );
  }
}

/// Live Activity lifecycle phases.
enum LiveActivityPhase {
  /// Activity started.
  started,

  /// Activity updated.
  updated,

  /// Activity ended.
  ended,

  /// Activity dismissed by the user / system.
  dismissed,
}

/// Fallback for unrecognized event types (forward-compatible).
final class FlowWidgetUnknownEvent extends FlowWidgetEvent {
  /// Creates an unknown event.
  const FlowWidgetUnknownEvent({
    required this.rawType,
    required super.timestamp,
  });

  /// Raw type string from the wire payload.
  final String rawType;
}
