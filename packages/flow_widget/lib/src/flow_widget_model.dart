import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

/// Contract for strongly typed widget data models.
///
/// Annotate classes with `@FlowWidgetModel()` and run `build_runner`
/// to generate efficient serializers that implement this interface.
/// Hand-written models simply implement [toEntries].
abstract interface class FlowWidgetEncodable {
  /// Converts this model into shared-storage entries.
  List<FlowWidgetDataEntry> toEntries();
}

/// Mixin that stores a model under a single JSON key for simple cases.
mixin FlowWidgetJsonModel implements FlowWidgetEncodable {
  /// Storage key used when persisting [toJsonString].
  String get storageKey;

  /// Encodes this model as a JSON string.
  String toJsonString();

  @override
  List<FlowWidgetDataEntry> toEntries() {
    return [
      FlowWidgetDataEntry(
        key: storageKey,
        value: FlowWidgetValue.json(toJsonString()),
      ),
    ];
  }
}
