import 'package:flow_widget/flow_widget.dart';
import 'package:flow_widget_example/main.dart';
import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _SilentPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FlowWidgetPlatform {
  @override
  Future<void> initialize(FlowWidgetOptions options) async {}

  @override
  Future<bool> get isInitialized async => true;

  @override
  Future<FlowWidgetCapabilities> getCapabilities() async =>
      const FlowWidgetCapabilities(homeWidgets: true);

  @override
  Future<FlowWidgetPlatformType> getPlatformType() async =>
      FlowWidgetPlatformType.android;

  @override
  Future<List<FlowWidgetInfo>> getInstalledWidgets() async => const [];

  @override
  Future<void> registerConfig(FlowWidgetConfig config) async {}

  @override
  Stream<FlowWidgetEvent> get events => const Stream.empty();

  @override
  Future<void> saveData({
    required String key,
    required FlowWidgetValue value,
    String? groupId,
  }) async {}

  @override
  Future<void> saveBatch({
    required List<FlowWidgetDataEntry> entries,
    String? groupId,
  }) async {}

  @override
  Future<FlowWidgetValue?> getData({
    required String key,
    String? groupId,
  }) async => null;

  @override
  Future<Map<String, FlowWidgetValue>> getAllData({
    String? prefix,
    String? groupId,
  }) async => {};

  @override
  Future<void> removeData({required String key, String? groupId}) async {}

  @override
  Future<void> clearData({String? groupId}) async {}

  @override
  Future<String> saveImage(FlowWidgetImage image) async => image.key;

  @override
  Future<void> removeImage({required String key}) async {}

  @override
  Future<void> update(FlowWidgetUpdateRequest request) async {}

  @override
  Future<void> updateMany(List<FlowWidgetUpdateRequest> requests) async {}

  @override
  Future<void> updateAll() async {}

  @override
  Future<void> setTimeline({
    required FlowWidgetId widgetId,
    required List<FlowWidgetTimelineEntry> entries,
  }) async {}

  @override
  Future<bool> requestPinWidget({
    required String name,
    Map<String, FlowWidgetValue>? initialData,
  }) async => false;

  @override
  Future<String> startLiveActivity(LiveActivityConfig config) async => 'x';

  @override
  Future<void> updateLiveActivity({
    required String activityId,
    required Map<String, FlowWidgetValue> data,
  }) async {}

  @override
  Future<void> endLiveActivity({
    required String activityId,
    Map<String, FlowWidgetValue>? finalData,
    DateTime? dismissalDate,
  }) async {}

  @override
  Future<List<LiveActivityState>> getActiveLiveActivities() async => const [];

  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlowWidgetPlatform.instance = _SilentPlatform();
    FlowWidget.debugReset();
    await FlowWidget.initialize();
  });

  testWidgets('home renders catalog', (tester) async {
    await tester.pumpWidget(const FlowWidgetExampleApp());
    await tester.pumpAndSettle();
    expect(find.text('flow_widget'), findsWidgets);
    expect(find.text('Weather'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Live Activities'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Live Activities'), findsOneWidget);
  });
}
