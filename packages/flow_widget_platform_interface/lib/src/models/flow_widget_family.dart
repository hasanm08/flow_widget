/// Logical family classifying where a widget appears.
enum FlowWidgetFamily {
  /// Home / today screen widgets.
  home,

  /// Lock-screen widgets (Android 4.2+ / iOS 16+).
  lockScreen,

  /// StandBy / Nightstand widgets (iOS 17+).
  standBy,

  /// Control Center widgets (macOS / iOS).
  controlCenter,

  /// Wear OS Tiles.
  wearTile,

  /// watchOS Complications.
  complication,

  /// Live Activity / Dynamic Island.
  liveActivity,
}
