import 'package:flow_widget/flow_widget.dart';
import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePlatform extends Fake
    with MockPlatformInterfaceMixin
    implements FlowWidgetPlatform {
  bool initialized = false;
  final Map<String, FlowWidgetValue> store = {};
  final List<FlowWidgetUpdateRequest> updates = [];

  @override
  Future<void> initialize(FlowWidgetOptions options) async {
    initialized = true;
  }

  @override
  Future<bool> get isInitialized async => initialized;

  @override
  Future<void> saveData({
    required String key,
    required FlowWidgetValue value,
    String? groupId,
  }) async {
    store[key] = value;
  }

  @override
  Future<void> saveBatch({
    required List<FlowWidgetDataEntry> entries,
    String? groupId,
  }) async {
    for (final e in entries) {
      store[e.key] = e.value;
    }
  }

  @override
  Future<FlowWidgetValue?> getData({
    required String key,
    String? groupId,
  }) async => store[key];

  @override
  Future<void> update(FlowWidgetUpdateRequest request) async {
    updates.add(request);
  }

  @override
  Future<void> updateAll() async {
    updates.add(const FlowWidgetUpdateRequest(name: '*'));
  }

  @override
  Future<FlowWidgetCapabilities> getCapabilities() async =>
      const FlowWidgetCapabilities(homeWidgets: true);

  @override
  Future<FlowWidgetPlatformType> getPlatformType() async =>
      FlowWidgetPlatformType.android;

  @override
  Future<List<FlowWidgetInfo>> getInstalledWidgets() async => const [];

  @override
  Future<Map<String, FlowWidgetValue>> getAllData({
    String? prefix,
    String? groupId,
  }) async => Map.of(store);

  @override
  Future<void> removeData({required String key, String? groupId}) async {
    store.remove(key);
  }

  @override
  Future<void> clearData({String? groupId}) async => store.clear();

  @override
  Future<String> saveImage(FlowWidgetImage image) async => image.key;

  @override
  Future<void> removeImage({required String key}) async {}

  @override
  Future<void> updateMany(List<FlowWidgetUpdateRequest> requests) async {
    updates.addAll(requests);
  }

  @override
  Future<void> setTimeline({
    required FlowWidgetId widgetId,
    required List<FlowWidgetTimelineEntry> entries,
  }) async {}

  @override
  Future<void> registerConfig(FlowWidgetConfig config) async {}

  @override
  Future<bool> requestPinWidget({
    required String name,
    Map<String, FlowWidgetValue>? initialData,
  }) async => true;

  @override
  Future<String> startLiveActivity(LiveActivityConfig config) async => 'act-1';

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
  Stream<FlowWidgetEvent> get events => const Stream.empty();

  @override
  Future<void> dispose() async {
    initialized = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePlatform fake;

  setUp(() {
    fake = _FakePlatform();
    FlowWidgetPlatform.instance = fake;
    FlowWidget.debugReset();
  });

  tearDown(FlowWidget.debugReset);

  test('initialize is required before APIs', () async {
    expect(
      () => FlowWidget.saveData(key: 'a', value: 'b'),
      throwsA(isA<FlowWidgetNotInitializedException>()),
    );

    await FlowWidget.initialize();
    await FlowWidget.saveData(key: 'a', value: 'b');
    expect(fake.store['a'], const FlowWidgetValue.string('b'));
  });

  test('saveBatch and update flow', () async {
    await FlowWidget.initialize();
    await FlowWidget.saveBatch(
      entries: const [
        FlowWidgetDataEntry(key: 'score', value: FlowWidgetValue.intValue(95)),
      ],
    );
    await FlowWidget.update(name: 'ProfileWidget', id: 3);
    expect(fake.store['score'], const FlowWidgetValue.intValue(95));
    expect(fake.updates.single.name, 'ProfileWidget');
    expect(fake.updates.single.id, 3);
  });

  test('typed getters', () async {
    await FlowWidget.initialize();
    await FlowWidget.saveData(key: 'n', value: 7);
    await FlowWidget.saveData(key: 'ok', value: true);
    expect(await FlowWidget.getInt(key: 'n'), 7);
    expect(await FlowWidget.getBool(key: 'ok'), isTrue);
    expect(await FlowWidget.getString(key: 'n'), isNull);
  });

  test('method channel initialize round-trip', () async {
    final channel = MethodChannelFlowWidget(
      methodChannel: const MethodChannel('dev.flow_widget/methods'),
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.flow_widget/methods'),
          (call) async {
            expect(call.method, 'initialize');
            return null;
          },
        );
    await channel.initialize(FlowWidgetOptions.defaults);
    expect(await channel.isInitialized, isTrue);
  });
}
