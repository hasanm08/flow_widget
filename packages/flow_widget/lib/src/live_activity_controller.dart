import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

import 'flow_widget.dart';

/// Controller for iOS Live Activities and Dynamic Island.
final class LiveActivityController {
  /// Creates a Live Activity controller.
  ///
  /// Prefer [FlowWidget.liveActivity] instead of constructing this directly.
  LiveActivityController();

  /// Starts a Live Activity.
  ///
  /// Throws [FlowWidgetUnsupportedException] on platforms without support.
  Future<String> start(LiveActivityConfig config) {
    _ensureReady();
    return FlowWidgetPlatform.instance.startLiveActivity(config);
  }

  /// Updates an active Live Activity's content state.
  Future<void> update({
    required String activityId,
    required Map<String, Object> data,
  }) {
    _ensureReady();
    return FlowWidgetPlatform.instance.updateLiveActivity(
      activityId: activityId,
      data: {for (final e in data.entries) e.key: FlowWidgetValue.box(e.value)},
    );
  }

  /// Ends a Live Activity.
  Future<void> end({
    required String activityId,
    Map<String, Object>? finalData,
    DateTime? dismissalDate,
  }) {
    _ensureReady();
    return FlowWidgetPlatform.instance.endLiveActivity(
      activityId: activityId,
      finalData: finalData == null
          ? null
          : {
              for (final e in finalData.entries)
                e.key: FlowWidgetValue.box(e.value),
            },
      dismissalDate: dismissalDate,
    );
  }

  /// Returns currently active Live Activities.
  Future<List<LiveActivityState>> getActive() {
    _ensureReady();
    return FlowWidgetPlatform.instance.getActiveLiveActivities();
  }

  void _ensureReady() {
    if (!FlowWidget.isInitialized) {
      throw const FlowWidgetNotInitializedException();
    }
  }
}
