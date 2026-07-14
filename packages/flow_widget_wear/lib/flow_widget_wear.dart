import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

/// Wear OS Tiles platform implementation for [FlowWidgetPlatform].
///
/// The host phone app must include a Wear OS module. This package provides the
/// MethodChannel bridge and tile update triggers; tile rendering is implemented
/// by subclasses of [FlowWidgetTileService] in the Wear module.
class FlowWidgetWear extends MethodChannelFlowWidget {
  /// Registers this implementation as the active [FlowWidgetPlatform] instance.
  static void registerWith() {
    FlowWidgetPlatform.instance = FlowWidgetWear();
  }
}
