import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

/// Windows platform implementation for [FlowWidgetPlatform].
///
/// Native method and event channels are registered by the C++ plugin.
/// Visual Windows desktop widgets are not supported; this package provides
/// SharedPreferences-like local storage only.
class FlowWidgetWindows extends MethodChannelFlowWidget {
  /// Registers this implementation as the active [FlowWidgetPlatform] instance.
  static void registerWith() {
    FlowWidgetPlatform.instance = FlowWidgetWindows();
  }
}
