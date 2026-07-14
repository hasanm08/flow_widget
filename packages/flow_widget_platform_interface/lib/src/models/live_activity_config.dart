import '../types/flow_widget_value.dart';

/// Configuration used to start a Live Activity / Dynamic Island session.
final class LiveActivityConfig {
  /// Creates a Live Activity configuration.
  const LiveActivityConfig({
    required this.attributesType,
    required this.data,
    this.activityId,
    this.staleDate,
    this.relevanceScore,
    this.enableDynamicIsland = true,
  });

  /// ActivityAttributes type name registered in the iOS extension.
  final String attributesType;

  /// Optional custom activity id. When null, the platform generates one.
  final String? activityId;

  /// Initial content-state data.
  final Map<String, FlowWidgetValue> data;

  /// Date after which the activity is considered stale.
  final DateTime? staleDate;

  /// Relevance score for prioritization (0.0 – 1.0).
  final double? relevanceScore;

  /// Whether Dynamic Island presentation is enabled.
  final bool enableDynamicIsland;

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'attributesType': attributesType,
    if (activityId != null) 'activityId': activityId,
    'data': <String, Object?>{
      for (final e in data.entries) e.key: e.value.toWire(),
    },
    if (staleDate != null)
      'staleDate': staleDate!.toUtc().millisecondsSinceEpoch,
    if (relevanceScore != null) 'relevanceScore': relevanceScore,
    'enableDynamicIsland': enableDynamicIsland,
  };
}
