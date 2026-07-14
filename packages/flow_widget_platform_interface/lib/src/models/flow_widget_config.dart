import '../types/flow_widget_size.dart';
import 'flow_widget_family.dart';

/// Static configuration for a widget family registered with flow_widget.
final class FlowWidgetConfig {
  /// Creates a widget configuration.
  const FlowWidgetConfig({
    required this.name,
    required this.displayName,
    this.description = '',
    this.supportedSizes = const [
      FlowWidgetSize.small,
      FlowWidgetSize.medium,
      FlowWidgetSize.large,
    ],
    this.family = FlowWidgetFamily.home,
    this.configurable = false,
    this.interactive = false,
    this.androidProviderFullyQualifiedName,
    this.iosKind,
    this.macosKind,
  });

  /// Unique Dart-side name (e.g. `"WeatherWidget"`).
  final String name;

  /// User-visible name shown in the widget gallery.
  final String displayName;

  /// User-visible description.
  final String description;

  /// Supported size classes.
  final List<FlowWidgetSize> supportedSizes;

  /// Widget family (home, lock screen, complications, etc.).
  final FlowWidgetFamily family;

  /// Whether the widget has a configuration / edit UI.
  final bool configurable;

  /// Whether the widget supports interactive controls.
  final bool interactive;

  /// Fully-qualified Android AppWidgetProvider / Glance class name.
  final String? androidProviderFullyQualifiedName;

  /// iOS WidgetKit kind string.
  final String? iosKind;

  /// macOS WidgetKit kind string.
  final String? macosKind;

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'name': name,
    'displayName': displayName,
    'description': description,
    'supportedSizes': [for (final s in supportedSizes) s.name],
    'family': family.name,
    'configurable': configurable,
    'interactive': interactive,
    if (androidProviderFullyQualifiedName != null)
      'androidProvider': androidProviderFullyQualifiedName,
    if (iosKind != null) 'iosKind': iosKind,
    if (macosKind != null) 'macosKind': macosKind,
  };
}
