/// Configuration passed to [FlowWidgetPlatform.initialize].
final class FlowWidgetOptions {
  /// Creates initialization options.
  const FlowWidgetOptions({
    this.appGroupId,
    this.androidNamedSharedPreferences,
    this.enableDebugLogging = false,
    this.batchChannelCalls = true,
    this.imageCacheMaxBytes = 20 * 1024 * 1024,
    this.useGlance = true,
  });

  /// Default options.
  static const FlowWidgetOptions defaults = FlowWidgetOptions();

  /// Default Android [SharedPreferences] file name when
  /// [androidNamedSharedPreferences] is null.
  ///
  /// Native Glance / RemoteViews code must pass this same string to
  /// `FlowWidgetStorage.create` (or the Kotlin constant
  /// `FlowWidgetStorage.DEFAULT_PREFS_NAME`).
  static const String defaultAndroidPrefsName = 'flutter_flow_widget';

  /// iOS / macOS App Group identifier for shared container access.
  ///
  /// **Android:** not used as a SharedPreferences name. Set
  /// [androidNamedSharedPreferences] (or rely on [defaultAndroidPrefsName])
  /// for Android storage.
  final String? appGroupId;

  /// Android SharedPreferences file name used by the plugin and by native
  /// widget code via `FlowWidgetStorage.create(context, prefsName)`.
  ///
  /// When null, Android uses [defaultAndroidPrefsName]
  /// (`flutter_flow_widget`). This value must match whatever your Glance
  /// receiver or `AppWidgetProvider` passes to `FlowWidgetStorage.create`;
  /// a mismatch means Flutter writes data the widget never reads.
  final String? androidNamedSharedPreferences;

  /// Enables verbose logging. Always disabled in release / profile when
  /// `kReleaseMode` / `kProfileMode` is true inside the app-facing package.
  final bool enableDebugLogging;

  /// When true, consecutive save/update calls within a short window are
  /// coalesced into a single MethodChannel invocation.
  final bool batchChannelCalls;

  /// Maximum on-disk image cache size in bytes.
  final int imageCacheMaxBytes;

  /// Prefer Jetpack Glance on Android when the host app provides Glance
  /// receivers. When true, native refresh calls Glance `updateAll` /
  /// per-id `update` (plus `ACTION_APPWIDGET_UPDATE`). When false, refresh
  /// uses RemoteViews collection invalidation instead.
  final bool useGlance;

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    if (appGroupId != null) 'appGroupId': appGroupId,
    if (androidNamedSharedPreferences != null)
      'androidPrefs': androidNamedSharedPreferences,
    'enableDebugLogging': enableDebugLogging,
    'batchChannelCalls': batchChannelCalls,
    'imageCacheMaxBytes': imageCacheMaxBytes,
    'useGlance': useGlance,
  };

  /// Returns a copy with selected fields replaced.
  FlowWidgetOptions copyWith({
    String? appGroupId,
    String? androidNamedSharedPreferences,
    bool? enableDebugLogging,
    bool? batchChannelCalls,
    int? imageCacheMaxBytes,
    bool? useGlance,
  }) {
    return FlowWidgetOptions(
      appGroupId: appGroupId ?? this.appGroupId,
      androidNamedSharedPreferences:
          androidNamedSharedPreferences ?? this.androidNamedSharedPreferences,
      enableDebugLogging: enableDebugLogging ?? this.enableDebugLogging,
      batchChannelCalls: batchChannelCalls ?? this.batchChannelCalls,
      imageCacheMaxBytes: imageCacheMaxBytes ?? this.imageCacheMaxBytes,
      useGlance: useGlance ?? this.useGlance,
    );
  }
}
