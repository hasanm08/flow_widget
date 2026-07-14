/// Identifies a platform on which flow_widget can host widgets.
enum FlowWidgetPlatformType {
  /// Android phone / tablet App Widgets & Glance.
  android,

  /// iOS WidgetKit, Live Activities, Dynamic Island.
  ios,

  /// macOS desktop widgets.
  macos,

  /// Windows Widgets (where publicly supported).
  windows,

  /// Linux desktop widgets (DE-dependent).
  linux,

  /// Wear OS Tiles.
  wearOs,

  /// watchOS Complications / WidgetKit.
  watchOs,

  /// Unsupported or unknown host.
  unsupported,
}
