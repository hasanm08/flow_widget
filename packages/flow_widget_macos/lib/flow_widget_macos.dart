import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

/// macOS platform implementation for [FlowWidgetPlatform].
///
/// Native method and event channels are registered by [FlowWidgetPlugin] in
/// Swift. This Dart class is available for tests and custom registration.
class FlowWidgetMacos extends MethodChannelFlowWidget {
  /// Registers this implementation as the active [FlowWidgetPlatform] instance.
  static void registerWith() {
    FlowWidgetPlatform.instance = FlowWidgetMacos();
  }
}
