import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'channels/flow_widget_method_channel.dart';
import 'events/flow_widget_event.dart';
import 'models/flow_widget_capabilities.dart';
import 'models/flow_widget_config.dart';
import 'models/flow_widget_data_entry.dart';
import 'models/flow_widget_id.dart';
import 'models/flow_widget_image.dart';
import 'models/flow_widget_info.dart';
import 'models/flow_widget_options.dart';
import 'models/flow_widget_timeline_entry.dart';
import 'models/flow_widget_update_request.dart';
import 'models/live_activity_config.dart';
import 'models/live_activity_state.dart';
import 'types/flow_widget_platform_type.dart';
import 'types/flow_widget_value.dart';

/// The interface that platform implementations of flow_widget must extend.
///
/// Platform packages register themselves by calling
/// `FlowWidgetPlatform.instance = MyPlatformImplementation()`.
///
/// Design notes:
/// - All methods are asynchronous to keep the UI thread free.
/// - Batch APIs (`saveBatch`, `updateMany`) exist to minimize MethodChannel
///   round-trips on constrained devices (Wear OS / watchOS).
/// - Prefer typed [FlowWidgetValue] over untyped `Object?` where possible.
abstract class FlowWidgetPlatform extends PlatformInterface {
  /// Constructs a [FlowWidgetPlatform].
  FlowWidgetPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlowWidgetPlatform _instance = MethodChannelFlowWidget();

  /// The default instance of [FlowWidgetPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlowWidget].
  static FlowWidgetPlatform get instance => _instance;

  /// Platform-specific implementations set this to their concrete class
  /// during plugin registration.
  static set instance(FlowWidgetPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initializes the platform plugin with [options].
  ///
  /// Must be called once before any other API. Idempotent on subsequent calls
  /// with identical options.
  Future<void> initialize(FlowWidgetOptions options) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Returns whether [initialize] has completed successfully.
  Future<bool> get isInitialized {
    throw UnimplementedError('isInitialized has not been implemented.');
  }

  /// Releases native resources. Rarely needed in production apps.
  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Capabilities & discovery
  // ---------------------------------------------------------------------------

  /// Returns the set of features supported by the current platform.
  Future<FlowWidgetCapabilities> getCapabilities() {
    throw UnimplementedError('getCapabilities() has not been implemented.');
  }

  /// Returns the active platform type.
  Future<FlowWidgetPlatformType> getPlatformType() {
    throw UnimplementedError('getPlatformType() has not been implemented.');
  }

  /// Lists all registered / installed widget instances.
  Future<List<FlowWidgetInfo>> getInstalledWidgets() {
    throw UnimplementedError('getInstalledWidgets() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Shared storage (App Groups / SharedPreferences / equivalent)
  // ---------------------------------------------------------------------------

  /// Persists a single typed [value] under [key].
  Future<void> saveData({
    required String key,
    required FlowWidgetValue value,
    String? groupId,
  }) {
    throw UnimplementedError('saveData() has not been implemented.');
  }

  /// Persists multiple entries in a single native round-trip.
  Future<void> saveBatch({
    required List<FlowWidgetDataEntry> entries,
    String? groupId,
  }) {
    throw UnimplementedError('saveBatch() has not been implemented.');
  }

  /// Reads a typed value for [key], or `null` if absent.
  Future<FlowWidgetValue?> getData({required String key, String? groupId}) {
    throw UnimplementedError('getData() has not been implemented.');
  }

  /// Reads all keys in the shared store (optionally filtered by [prefix]).
  Future<Map<String, FlowWidgetValue>> getAllData({
    String? prefix,
    String? groupId,
  }) {
    throw UnimplementedError('getAllData() has not been implemented.');
  }

  /// Removes [key] from shared storage.
  Future<void> removeData({required String key, String? groupId}) {
    throw UnimplementedError('removeData() has not been implemented.');
  }

  /// Clears all shared storage for the given [groupId] (or default).
  Future<void> clearData({String? groupId}) {
    throw UnimplementedError('clearData() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  /// Saves image bytes (or a remote URL to be cached) for widget use.
  Future<String> saveImage(FlowWidgetImage image) {
    throw UnimplementedError('saveImage() has not been implemented.');
  }

  /// Removes a previously saved image by [key].
  Future<void> removeImage({required String key}) {
    throw UnimplementedError('removeImage() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Widget updates
  // ---------------------------------------------------------------------------

  /// Triggers a refresh for one or more widgets described by [request].
  Future<void> update(FlowWidgetUpdateRequest request) {
    throw UnimplementedError('update() has not been implemented.');
  }

  /// Triggers refreshes for multiple widgets in one native call.
  Future<void> updateMany(List<FlowWidgetUpdateRequest> requests) {
    throw UnimplementedError('updateMany() has not been implemented.');
  }

  /// Refreshes every registered widget of every family.
  Future<void> updateAll() {
    throw UnimplementedError('updateAll() has not been implemented.');
  }

  /// Sets a timeline of future states (WidgetKit / Glance timeline).
  Future<void> setTimeline({
    required FlowWidgetId widgetId,
    required List<FlowWidgetTimelineEntry> entries,
  }) {
    throw UnimplementedError('setTimeline() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// Registers widget family metadata used by native hosts and the CLI.
  Future<void> registerConfig(FlowWidgetConfig config) {
    throw UnimplementedError('registerConfig() has not been implemented.');
  }

  /// Requests that the OS present a pin / add-widget UI when supported.
  Future<bool> requestPinWidget({
    required String name,
    Map<String, FlowWidgetValue>? initialData,
  }) {
    throw UnimplementedError('requestPinWidget() has not been implemented.');
  }

  // ---------------------------------------------------------------------------
  // Live Activities / Dynamic Island (iOS)
  // ---------------------------------------------------------------------------

  /// Starts a Live Activity with the given [config].
  Future<String> startLiveActivity(LiveActivityConfig config) {
    throw UnimplementedError('startLiveActivity() has not been implemented.');
  }

  /// Updates an active Live Activity identified by [activityId].
  Future<void> updateLiveActivity({
    required String activityId,
    required Map<String, FlowWidgetValue> data,
  }) {
    throw UnimplementedError('updateLiveActivity() has not been implemented.');
  }

  /// Ends a Live Activity.
  Future<void> endLiveActivity({
    required String activityId,
    Map<String, FlowWidgetValue>? finalData,
    DateTime? dismissalDate,
  }) {
    throw UnimplementedError('endLiveActivity() has not been implemented.');
  }

  /// Returns currently active Live Activities.
  Future<List<LiveActivityState>> getActiveLiveActivities() {
    throw UnimplementedError(
      'getActiveLiveActivities() has not been implemented.',
    );
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  /// Broadcast stream of platform events (clicks, configurations, etc.).
  Stream<FlowWidgetEvent> get events {
    throw UnimplementedError('events has not been implemented.');
  }
}
