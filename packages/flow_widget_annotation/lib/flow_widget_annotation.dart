/// Annotations used by `flow_widget_generator`.
library;

/// Marks a class as a strongly typed flow_widget data model.
///
/// ```dart
/// @FlowWidgetModel(prefix: 'dashboard_')
/// class DashboardData {
///   const DashboardData({required this.score});
///   final int score;
/// }
/// ```
///
/// Running `dart run build_runner build` generates:
/// - `toEntries()` / `fromEntries()` serializers
/// - `save()` / `update()` extension helpers
/// - Native binding hints for the CLI
final class FlowWidgetModel {
  /// Creates a model annotation.
  const FlowWidgetModel({
    this.prefix = '',
    this.storageKey,
    this.generateJson = true,
  });

  /// Optional key prefix applied to every generated field entry.
  final String prefix;

  /// When set, the entire model is stored as one JSON blob under this key
  /// instead of per-field entries.
  final String? storageKey;

  /// Whether to also generate `toJson` / `fromJson`.
  final bool generateJson;
}

/// Marks a field to be excluded from generated serializers.
final class FlowWidgetIgnore {
  /// Creates an ignore annotation.
  const FlowWidgetIgnore();
}

/// Convenience constant for [FlowWidgetIgnore].
const flowWidgetIgnore = FlowWidgetIgnore();

/// Overrides the storage key for a single field.
final class FlowWidgetKey {
  /// Creates a key override.
  const FlowWidgetKey(this.name);

  /// Custom storage key.
  final String name;
}
