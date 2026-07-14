/// Cross-platform home widget framework for Flutter.
///
/// ```dart
/// await FlowWidget.initialize();
///
/// await FlowWidget.saveData(key: 'username', value: 'Amir');
/// await FlowWidget.update(name: 'ProfileWidget');
///
/// FlowWidget.onClicked.listen((event) {
///   // Handle widget interaction
/// });
/// ```
library;

export 'package:flow_widget_annotation/flow_widget_annotation.dart';
export 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart'
    show
        FlowWidgetCapabilities,
        FlowWidgetClickEvent,
        FlowWidgetConfig,
        FlowWidgetConfiguredEvent,
        FlowWidgetDataEntry,
        FlowWidgetEvent,
        FlowWidgetException,
        FlowWidgetFamily,
        FlowWidgetId,
        FlowWidgetImage,
        FlowWidgetImageCachePolicy,
        FlowWidgetInfo,
        FlowWidgetLiveActivityEvent,
        FlowWidgetLiveActivityException,
        FlowWidgetNotInitializedException,
        FlowWidgetOptions,
        FlowWidgetPlatformType,
        FlowWidgetSize,
        FlowWidgetStorageException,
        FlowWidgetTimelineEntry,
        FlowWidgetTimelineReloadEvent,
        FlowWidgetUnsupportedException,
        FlowWidgetUpdateException,
        FlowWidgetUpdateRequest,
        FlowWidgetValue,
        LiveActivityConfig,
        LiveActivityPhase,
        LiveActivityState;

export 'src/flow_widget.dart';
export 'src/flow_widget_model.dart'
    show FlowWidgetEncodable, FlowWidgetJsonModel;
export 'src/live_activity_controller.dart';
export 'src/logging/flow_widget_logger.dart';
