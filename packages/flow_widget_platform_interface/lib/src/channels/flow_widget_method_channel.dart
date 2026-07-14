import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../events/flow_widget_event.dart';
import '../exceptions/flow_widget_exception.dart';
import '../flow_widget_platform.dart';
import '../models/flow_widget_capabilities.dart';
import '../models/flow_widget_config.dart';
import '../models/flow_widget_data_entry.dart';
import '../models/flow_widget_id.dart';
import '../models/flow_widget_image.dart';
import '../models/flow_widget_info.dart';
import '../models/flow_widget_options.dart';
import '../models/flow_widget_timeline_entry.dart';
import '../models/flow_widget_update_request.dart';
import '../models/live_activity_config.dart';
import '../models/live_activity_state.dart';
import '../types/flow_widget_platform_type.dart';
import '../types/flow_widget_value.dart';

/// Default [FlowWidgetPlatform] implementation using Method/Event channels.
///
/// Channel names are stable public contracts — do not rename without a
/// major version bump.
class MethodChannelFlowWidget extends FlowWidgetPlatform {
  /// Creates a method-channel backed implementation.
  MethodChannelFlowWidget({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : methodChannel =
           methodChannel ?? const MethodChannel('dev.flow_widget/methods'),
       eventChannel =
           eventChannel ?? const EventChannel('dev.flow_widget/events');

  /// Method channel for request/response RPCs.
  @visibleForTesting
  final MethodChannel methodChannel;

  /// Event channel for click / lifecycle broadcasts.
  @visibleForTesting
  final EventChannel eventChannel;

  StreamController<FlowWidgetEvent>? _eventsController;
  StreamSubscription<dynamic>? _eventsSubscription;
  bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> initialize(FlowWidgetOptions options) async {
    try {
      await methodChannel.invokeMethod<void>('initialize', options.toWire());
      _initialized = true;
      _ensureEventStream();
    } on PlatformException catch (e, st) {
      Error.throwWithStackTrace(
        FlowWidgetException(
          e.message ?? 'Failed to initialize flow_widget',
          code: e.code,
          cause: e,
        ),
        st,
      );
    }
  }

  @override
  Future<bool> get isInitialized async => _initialized;

  @override
  Future<void> dispose() async {
    await _eventsSubscription?.cancel();
    await _eventsController?.close();
    _eventsSubscription = null;
    _eventsController = null;
    _initialized = false;
    try {
      await methodChannel.invokeMethod<void>('dispose');
    } on MissingPluginException {
      // Host may already be torn down.
    }
  }

  // ---------------------------------------------------------------------------
  // Capabilities
  // ---------------------------------------------------------------------------

  @override
  Future<FlowWidgetCapabilities> getCapabilities() async {
    final result = await _invokeMap('getCapabilities');
    return FlowWidgetCapabilities.fromWire(result);
  }

  @override
  Future<FlowWidgetPlatformType> getPlatformType() async {
    final result = await methodChannel.invokeMethod<String>('getPlatformType');
    if (result == null) return FlowWidgetPlatformType.unsupported;
    return FlowWidgetPlatformType.values.byName(result);
  }

  @override
  Future<List<FlowWidgetInfo>> getInstalledWidgets() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getInstalledWidgets',
    );
    if (result == null) return const [];
    return [
      for (final item in result)
        FlowWidgetInfo.fromWire(Map<Object?, Object?>.from(item as Map)),
    ];
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveData({
    required String key,
    required FlowWidgetValue value,
    String? groupId,
  }) {
    return _invoke('saveData', <String, Object?>{
      'key': key,
      'value': value.toWire(),
      if (groupId != null) 'groupId': groupId,
    });
  }

  @override
  Future<void> saveBatch({
    required List<FlowWidgetDataEntry> entries,
    String? groupId,
  }) {
    return _invoke('saveBatch', <String, Object?>{
      'entries': [for (final e in entries) e.toWire()],
      if (groupId != null) 'groupId': groupId,
    });
  }

  @override
  Future<FlowWidgetValue?> getData({
    required String key,
    String? groupId,
  }) async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getData',
      <String, Object?>{'key': key, if (groupId != null) 'groupId': groupId},
    );
    if (result == null) return null;
    return FlowWidgetValue.fromWire(result);
  }

  @override
  Future<Map<String, FlowWidgetValue>> getAllData({
    String? prefix,
    String? groupId,
  }) async {
    final result = await _invokeMap('getAllData', <String, Object?>{
      if (prefix != null) 'prefix': prefix,
      if (groupId != null) 'groupId': groupId,
    });
    return {
      for (final e in result.entries)
        e.key! as String: FlowWidgetValue.fromWire(
          Map<Object?, Object?>.from(e.value! as Map),
        ),
    };
  }

  @override
  Future<void> removeData({required String key, String? groupId}) {
    return _invoke('removeData', <String, Object?>{
      'key': key,
      if (groupId != null) 'groupId': groupId,
    });
  }

  @override
  Future<void> clearData({String? groupId}) {
    return _invoke('clearData', <String, Object?>{
      if (groupId != null) 'groupId': groupId,
    });
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  @override
  Future<String> saveImage(FlowWidgetImage image) async {
    final path = await methodChannel.invokeMethod<String>(
      'saveImage',
      image.toWire(),
    );
    if (path == null) {
      throw const FlowWidgetStorageException('saveImage returned null path');
    }
    return path;
  }

  @override
  Future<void> removeImage({required String key}) {
    return _invoke('removeImage', <String, Object?>{'key': key});
  }

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  @override
  Future<void> update(FlowWidgetUpdateRequest request) {
    return _invoke('update', request.toWire());
  }

  @override
  Future<void> updateMany(List<FlowWidgetUpdateRequest> requests) {
    return _invoke('updateMany', <String, Object?>{
      'requests': [for (final r in requests) r.toWire()],
    });
  }

  @override
  Future<void> updateAll() => _invoke('updateAll');

  @override
  Future<void> setTimeline({
    required FlowWidgetId widgetId,
    required List<FlowWidgetTimelineEntry> entries,
  }) {
    return _invoke('setTimeline', <String, Object?>{
      'widgetId': widgetId.toWire(),
      'entries': [for (final e in entries) e.toWire()],
    });
  }

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  @override
  Future<void> registerConfig(FlowWidgetConfig config) {
    return _invoke('registerConfig', config.toWire());
  }

  @override
  Future<bool> requestPinWidget({
    required String name,
    Map<String, FlowWidgetValue>? initialData,
  }) async {
    final result = await methodChannel.invokeMethod<bool>(
      'requestPinWidget',
      <String, Object?>{
        'name': name,
        if (initialData != null)
          'initialData': <String, Object?>{
            for (final e in initialData.entries) e.key: e.value.toWire(),
          },
      },
    );
    return result ?? false;
  }

  // ---------------------------------------------------------------------------
  // Live Activities
  // ---------------------------------------------------------------------------

  @override
  Future<String> startLiveActivity(LiveActivityConfig config) async {
    final id = await methodChannel.invokeMethod<String>(
      'startLiveActivity',
      config.toWire(),
    );
    if (id == null) {
      throw const FlowWidgetLiveActivityException(
        'startLiveActivity returned null activity id',
      );
    }
    return id;
  }

  @override
  Future<void> updateLiveActivity({
    required String activityId,
    required Map<String, FlowWidgetValue> data,
  }) {
    return _invoke('updateLiveActivity', <String, Object?>{
      'activityId': activityId,
      'data': <String, Object?>{
        for (final e in data.entries) e.key: e.value.toWire(),
      },
    });
  }

  @override
  Future<void> endLiveActivity({
    required String activityId,
    Map<String, FlowWidgetValue>? finalData,
    DateTime? dismissalDate,
  }) {
    return _invoke('endLiveActivity', <String, Object?>{
      'activityId': activityId,
      if (finalData != null)
        'finalData': <String, Object?>{
          for (final e in finalData.entries) e.key: e.value.toWire(),
        },
      if (dismissalDate != null)
        'dismissalDate': dismissalDate.toUtc().millisecondsSinceEpoch,
    });
  }

  @override
  Future<List<LiveActivityState>> getActiveLiveActivities() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>(
      'getActiveLiveActivities',
    );
    if (result == null) return const [];
    return [
      for (final item in result)
        LiveActivityState.fromWire(Map<Object?, Object?>.from(item as Map)),
    ];
  }

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

  @override
  Stream<FlowWidgetEvent> get events {
    _ensureEventStream();
    return _eventsController!.stream;
  }

  void _ensureEventStream() {
    if (_eventsController != null) return;
    _eventsController = StreamController<FlowWidgetEvent>.broadcast(
      onListen: () {
        _eventsSubscription ??= eventChannel.receiveBroadcastStream().listen(
          _onPlatformEvent,
          onError: _eventsController?.addError,
        );
      },
      onCancel: () async {
        if (!(_eventsController?.hasListener ?? false)) {
          await _eventsSubscription?.cancel();
          _eventsSubscription = null;
        }
      },
    );
  }

  void _onPlatformEvent(dynamic event) {
    if (event is! Map) return;
    try {
      _eventsController?.add(
        FlowWidgetEvent.fromWire(Map<Object?, Object?>.from(event)),
      );
    } on Object catch (e, st) {
      _eventsController?.addError(e, st);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> _invoke(String method, [Map<String, Object?>? args]) async {
    try {
      await methodChannel.invokeMethod<void>(method, args);
    } on PlatformException catch (e, st) {
      Error.throwWithStackTrace(
        FlowWidgetException(
          e.message ?? 'Native call "$method" failed',
          code: e.code,
          cause: e,
        ),
        st,
      );
    }
  }

  Future<Map<Object?, Object?>> _invokeMap(
    String method, [
    Map<String, Object?>? args,
  ]) async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        method,
        args,
      );
      return result ?? const <Object?, Object?>{};
    } on PlatformException catch (e, st) {
      Error.throwWithStackTrace(
        FlowWidgetException(
          e.message ?? 'Native call "$method" failed',
          code: e.code,
          cause: e,
        ),
        st,
      );
    }
  }
}
