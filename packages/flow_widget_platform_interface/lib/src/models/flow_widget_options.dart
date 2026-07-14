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

  /// iOS / macOS App Group identifier for shared container access.
  final String? appGroupId;

  /// Optional Android SharedPreferences file name.
  ///
  /// Defaults to `"flutter_flow_widget"` when null.
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
  /// receivers. Falls back to RemoteViews otherwise.
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
