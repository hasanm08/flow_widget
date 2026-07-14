import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

/// Linux platform implementation for [FlowWidgetPlatform].
///
/// Native method and event channels are registered by the GTK plugin.
/// Visual Linux desktop widgets depend on the desktop environment (GNOME
/// extensions, KDE plasmoids) and are not handled by this package directly.
class FlowWidgetLinux extends MethodChannelFlowWidget {
  /// Registers this implementation as the active [FlowWidgetPlatform] instance.
  static void registerWith() {
    FlowWidgetPlatform.instance = FlowWidgetLinux();
  }
}
