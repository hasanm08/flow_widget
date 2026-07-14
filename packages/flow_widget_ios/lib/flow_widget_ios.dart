import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

export 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart'
    show MethodChannelFlowWidget;

/// iOS implementation of [FlowWidgetPlatform].
///
/// The native [FlowWidgetPlugin] registers the method and event channels.
/// This Dart class is a thin optional override for tests or custom channel
/// wiring.
class FlowWidgetIOS extends MethodChannelFlowWidget {
  /// Creates the iOS platform implementation.
  FlowWidgetIOS();
}
