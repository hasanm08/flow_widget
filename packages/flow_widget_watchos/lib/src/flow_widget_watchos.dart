import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

/// watchOS Complications platform implementation for [FlowWidgetPlatform].
///
/// watchOS apps are native Watch extensions — Flutter does not run on watchOS.
/// This class uses the shared MethodChannel when invoked from the paired iOS host
/// app. Typed data is written to an App Group that the Watch extension reads via
/// the Swift helpers in `watchos/`.
///
/// Native watchOS code is generated into the Watch extension target by
/// `flow_widget_cli`; the Swift sources in this package are the canonical
/// templates for that output.
class FlowWidgetWatchOs extends MethodChannelFlowWidget {
  /// Creates the watchOS channel-backed implementation.
  FlowWidgetWatchOs({super.methodChannel, super.eventChannel});

  /// Registers this implementation as the active [FlowWidgetPlatform] instance.
  static void registerWith() {
    FlowWidgetPlatform.instance = FlowWidgetWatchOs();
  }
}
