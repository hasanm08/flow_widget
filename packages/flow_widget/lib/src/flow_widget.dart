import 'dart:async';

import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'flow_widget_model.dart';
import 'live_activity_controller.dart';
import 'logging/flow_widget_logger.dart';

/// Primary entry point for the flow_widget plugin.
///
/// All methods are static and process-wide. Call [initialize] once during
/// app startup (typically in `main()` before `runApp`).
///
/// Performance characteristics:
/// - Lazy platform registration (federated default packages).
/// - Optional call batching via [FlowWidgetOptions.batchChannelCalls].
/// - Typed [FlowWidgetValue] codec avoids reflection and runtime type checks.
/// - Debug logging is compiled out of release builds.
abstract final class FlowWidget {
  static bool _initialized = false;
  static FlowWidgetOptions _options = FlowWidgetOptions.defaults;
  static final LiveActivityController _liveActivity = LiveActivityController();

  /// Live Activity / Dynamic Island controller (iOS).
  static LiveActivityController get liveActivity => _liveActivity;

  /// Whether [initialize] has completed successfully.
  static bool get isInitialized => _initialized;

  /// Active options (valid after [initialize]).
  static FlowWidgetOptions get options => _options;

  /// Initializes the plugin.
  ///
  /// Idempotent when called repeatedly with equal options.
  static Future<void> initialize({
    FlowWidgetOptions options = FlowWidgetOptions.defaults,
  }) async {
    if (_initialized) {
      FlowWidgetLogger.debug('initialize() skipped — already initialized');
      return;
    }

    final effective = options.copyWith(
      enableDebugLogging: options.enableDebugLogging && !kReleaseMode,
    );
    FlowWidgetLogger.enabled = effective.enableDebugLogging;
    FlowWidgetLogger.debug('Initializing with options=$effective');

    await FlowWidgetPlatform.instance.initialize(effective);
    _options = effective;
    _initialized = true;
    FlowWidgetLogger.debug('Initialized successfully');
  }

  /// Ensures the plugin is initialized, throwing otherwise.
  static void _ensureInitialized() {
    if (!_initialized) {
      throw const FlowWidgetNotInitializedException();
    }
  }

  // ---------------------------------------------------------------------------
  // Capabilities
  // ---------------------------------------------------------------------------

  /// Returns host platform capabilities.
  static Future<FlowWidgetCapabilities> getCapabilities() {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.getCapabilities();
  }

  /// Returns the active platform type.
  static Future<FlowWidgetPlatformType> getPlatformType() {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.getPlatformType();
  }

  /// Lists installed widget instances.
  static Future<List<FlowWidgetInfo>> getInstalledWidgets() {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.getInstalledWidgets();
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  /// Persists a Dart primitive or [FlowWidgetValue] under [key].
  ///
  /// Supported [value] types match [FlowWidgetValue.box].
  static Future<void> saveData({
    required String key,
    required Object value,
    String? groupId,
  }) {
    _ensureInitialized();
    final typed = value is FlowWidgetValue ? value : FlowWidgetValue.box(value);
    FlowWidgetLogger.debug('saveData(key=$key)');
    return FlowWidgetPlatform.instance.saveData(
      key: key,
      value: typed,
      groupId: groupId,
    );
  }

  /// Persists a typed [FlowWidgetEncodable] (typically code-generated).
  static Future<void> save(FlowWidgetEncodable model, {String? groupId}) {
    _ensureInitialized();
    final entries = model.toEntries();
    FlowWidgetLogger.debug(
      'save(model=${model.runtimeType}, entries=${entries.length})',
    );
    return FlowWidgetPlatform.instance.saveBatch(
      entries: entries,
      groupId: groupId,
    );
  }

  /// Persists multiple entries in one native round-trip.
  static Future<void> saveBatch({
    required List<FlowWidgetDataEntry> entries,
    String? groupId,
  }) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.saveBatch(
      entries: entries,
      groupId: groupId,
    );
  }

  /// Reads a typed value for [key].
  static Future<FlowWidgetValue?> getData({
    required String key,
    String? groupId,
  }) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.getData(key: key, groupId: groupId);
  }

  /// Reads a string value, or `null` if absent / wrong type.
  static Future<String?> getString({
    required String key,
    String? groupId,
  }) async {
    final value = await getData(key: key, groupId: groupId);
    return value is FlowWidgetStringValue ? value.value : null;
  }

  /// Reads an int value, or `null` if absent / wrong type.
  static Future<int?> getInt({required String key, String? groupId}) async {
    final value = await getData(key: key, groupId: groupId);
    return value is FlowWidgetIntValue ? value.value : null;
  }

  /// Reads a bool value, or `null` if absent / wrong type.
  static Future<bool?> getBool({required String key, String? groupId}) async {
    final value = await getData(key: key, groupId: groupId);
    return value is FlowWidgetBoolValue ? value.value : null;
  }

  /// Reads all shared data, optionally filtered by [prefix].
  static Future<Map<String, FlowWidgetValue>> getAllData({
    String? prefix,
    String? groupId,
  }) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.getAllData(
      prefix: prefix,
      groupId: groupId,
    );
  }

  /// Removes [key] from shared storage.
  static Future<void> removeData({required String key, String? groupId}) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.removeData(key: key, groupId: groupId);
  }

  /// Clears shared storage.
  static Future<void> clearData({String? groupId}) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.clearData(groupId: groupId);
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  /// Saves an image for widget rendering. Returns the native file path.
  static Future<String> saveImage(FlowWidgetImage image) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.saveImage(image);
  }

  /// Removes a previously saved image.
  static Future<void> removeImage({required String key}) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.removeImage(key: key);
  }

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Triggers a widget refresh.
  ///
  /// ```dart
  /// await FlowWidget.update(name: 'ProfileWidget');
  /// await FlowWidget.update(name: 'ProfileWidget', id: 42);
  /// ```
  static Future<void> update({
    required String name,
    int? id,
    Map<String, Object>? data,
    bool reloadTimeline = true,
  }) {
    _ensureInitialized();
    final typedData = data == null
        ? null
        : <String, FlowWidgetValue>{
            for (final e in data.entries) e.key: FlowWidgetValue.box(e.value),
          };
    FlowWidgetLogger.debug('update(name=$name, id=$id)');
    return FlowWidgetPlatform.instance.update(
      FlowWidgetUpdateRequest(
        name: name,
        id: id,
        data: typedData,
        reloadTimeline: reloadTimeline,
      ),
    );
  }

  /// Updates multiple widgets in one native call.
  static Future<void> updateMany(List<FlowWidgetUpdateRequest> requests) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.updateMany(requests);
  }

  /// Refreshes every registered widget.
  static Future<void> updateAll() {
    _ensureInitialized();
    FlowWidgetLogger.debug('updateAll()');
    return FlowWidgetPlatform.instance.updateAll();
  }

  /// Saves [model] then updates the widget named [name].
  static Future<void> saveAndUpdate(
    FlowWidgetEncodable model, {
    required String name,
    int? id,
    String? groupId,
  }) async {
    await save(model, groupId: groupId);
    await update(name: name, id: id);
  }

  /// Publishes a timeline of future snapshots.
  static Future<void> setTimeline({
    required String name,
    required List<FlowWidgetTimelineEntry> entries,
    int? id,
  }) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.setTimeline(
      widgetId: FlowWidgetId(name: name, id: id),
      entries: entries,
    );
  }

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// Registers widget family metadata with the native host.
  static Future<void> registerConfig(FlowWidgetConfig config) {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.registerConfig(config);
  }

  /// Requests that the OS show a pin-widget UI (Android 8+).
  static Future<bool> requestPinWidget({
    required String name,
    Map<String, Object>? initialData,
  }) {
    _ensureInitialized();
    final typed = initialData == null
        ? null
        : <String, FlowWidgetValue>{
            for (final e in initialData.entries)
              e.key: FlowWidgetValue.box(e.value),
          };
    return FlowWidgetPlatform.instance.requestPinWidget(
      name: name,
      initialData: typed,
    );
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  /// All platform events (clicks, configurations, Live Activities, …).
  static Stream<FlowWidgetEvent> get events {
    _ensureInitialized();
    return FlowWidgetPlatform.instance.events;
  }

  /// Convenience stream of click / interaction events only.
  static Stream<FlowWidgetClickEvent> get onClicked {
    return events.where((e) => e is FlowWidgetClickEvent).cast();
  }

  /// Convenience stream of configuration events only.
  static Stream<FlowWidgetConfiguredEvent> get onConfigured {
    return events.where((e) => e is FlowWidgetConfiguredEvent).cast();
  }

  /// Releases resources. Rarely required in production apps.
  static Future<void> dispose() async {
    if (!_initialized) return;
    await FlowWidgetPlatform.instance.dispose();
    _initialized = false;
  }

  /// Resets initialization state. For tests only.
  @visibleForTesting
  static void debugReset() {
    _initialized = false;
    _options = FlowWidgetOptions.defaults;
    FlowWidgetLogger.enabled = false;
  }
}
