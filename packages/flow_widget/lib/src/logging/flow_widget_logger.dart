import 'package:flutter/foundation.dart';

/// Internal logger. Disabled in release builds and unless explicitly enabled.
abstract final class FlowWidgetLogger {
  /// Whether debug logging is enabled.
  static bool enabled = false;

  /// Logs a debug message when [enabled] is true.
  static void debug(String message) {
    if (!enabled || kReleaseMode) return;
    debugPrint('[flow_widget] $message');
  }

  /// Logs a warning. Suppressed in release unless [force] is true.
  static void warn(String message, {bool force = false}) {
    if (kReleaseMode && !force) return;
    debugPrint('[flow_widget][WARN] $message');
  }
}
