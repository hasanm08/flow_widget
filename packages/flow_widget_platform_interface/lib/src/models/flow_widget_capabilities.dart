/// Feature flags describing what the current host platform can do.
final class FlowWidgetCapabilities {
  /// Creates a capabilities snapshot.
  const FlowWidgetCapabilities({
    this.homeWidgets = false,
    this.lockScreenWidgets = false,
    this.interactiveWidgets = false,
    this.configurableWidgets = false,
    this.timelineProviders = false,
    this.liveActivities = false,
    this.dynamicIsland = false,
    this.pinWidget = false,
    this.backgroundUpdates = false,
    this.scheduledUpdates = false,
    this.pushUpdates = false,
    this.remoteImageCaching = false,
    this.appGroups = false,
    this.wearTiles = false,
    this.complications = false,
    this.multipleInstances = false,
    this.resizing = false,
    this.themeSynchronization = false,
    this.appIntents = false,
  });

  /// No capabilities (unsupported platform).
  static const FlowWidgetCapabilities none = FlowWidgetCapabilities();

  /// Home / today screen widgets.
  final bool homeWidgets;

  /// Lock-screen widgets.
  final bool lockScreenWidgets;

  /// Interactive controls inside widgets.
  final bool interactiveWidgets;

  /// Configuration / edit activities.
  final bool configurableWidgets;

  /// Timeline-based updates.
  final bool timelineProviders;

  /// Live Activities.
  final bool liveActivities;

  /// Dynamic Island presentations.
  final bool dynamicIsland;

  /// OS-level "pin widget" request API.
  final bool pinWidget;

  /// Background update mechanisms.
  final bool backgroundUpdates;

  /// Scheduled / periodic updates.
  final bool scheduledUpdates;

  /// Push-triggered updates.
  final bool pushUpdates;

  /// Native remote image download + cache.
  final bool remoteImageCaching;

  /// App Groups / shared container.
  final bool appGroups;

  /// Wear OS Tiles.
  final bool wearTiles;

  /// watchOS Complications.
  final bool complications;

  /// Multiple instances of the same family.
  final bool multipleInstances;

  /// User-driven resizing.
  final bool resizing;

  /// System theme / Material You sync.
  final bool themeSynchronization;

  /// App Intents integration.
  final bool appIntents;

  /// Wire decoding.
  factory FlowWidgetCapabilities.fromWire(Map<Object?, Object?> wire) {
    bool flag(String key) => wire[key] == true;

    return FlowWidgetCapabilities(
      homeWidgets: flag('homeWidgets'),
      lockScreenWidgets: flag('lockScreenWidgets'),
      interactiveWidgets: flag('interactiveWidgets'),
      configurableWidgets: flag('configurableWidgets'),
      timelineProviders: flag('timelineProviders'),
      liveActivities: flag('liveActivities'),
      dynamicIsland: flag('dynamicIsland'),
      pinWidget: flag('pinWidget'),
      backgroundUpdates: flag('backgroundUpdates'),
      scheduledUpdates: flag('scheduledUpdates'),
      pushUpdates: flag('pushUpdates'),
      remoteImageCaching: flag('remoteImageCaching'),
      appGroups: flag('appGroups'),
      wearTiles: flag('wearTiles'),
      complications: flag('complications'),
      multipleInstances: flag('multipleInstances'),
      resizing: flag('resizing'),
      themeSynchronization: flag('themeSynchronization'),
      appIntents: flag('appIntents'),
    );
  }

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'homeWidgets': homeWidgets,
    'lockScreenWidgets': lockScreenWidgets,
    'interactiveWidgets': interactiveWidgets,
    'configurableWidgets': configurableWidgets,
    'timelineProviders': timelineProviders,
    'liveActivities': liveActivities,
    'dynamicIsland': dynamicIsland,
    'pinWidget': pinWidget,
    'backgroundUpdates': backgroundUpdates,
    'scheduledUpdates': scheduledUpdates,
    'pushUpdates': pushUpdates,
    'remoteImageCaching': remoteImageCaching,
    'appGroups': appGroups,
    'wearTiles': wearTiles,
    'complications': complications,
    'multipleInstances': multipleInstances,
    'resizing': resizing,
    'themeSynchronization': themeSynchronization,
    'appIntents': appIntents,
  };
}
