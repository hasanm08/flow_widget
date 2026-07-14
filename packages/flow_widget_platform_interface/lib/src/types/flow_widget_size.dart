/// Canonical size classes for home-screen widgets.
///
/// Platforms map these to their native size families
/// (e.g. WidgetKit `systemSmall` / App Widget `minWidth`).
enum FlowWidgetSize {
  /// Smallest single-cell / accessory size.
  small,

  /// Medium rectangular size.
  medium,

  /// Large square / multi-row size.
  large,

  /// Extra-large (iPad / desktop).
  extraLarge,

  /// Lock-screen / accessory circular.
  accessoryCircular,

  /// Lock-screen / accessory rectangular.
  accessoryRectangular,

  /// Lock-screen / accessory inline.
  accessoryInline,

  /// Custom size defined by the host platform.
  custom,
}
