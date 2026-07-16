import 'package:flutter_test/flutter_test.dart';
import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';

void main() {
  group('FlowWidgetOptions', () {
    test('defaultAndroidPrefsName is stable and documented', () {
      expect(
        FlowWidgetOptions.defaultAndroidPrefsName,
        'flutter_flow_widget',
      );
    });

    test('toWire omits null android prefs and includes useGlance', () {
      const options = FlowWidgetOptions(
        appGroupId: 'group.com.example',
        useGlance: true,
      );
      final wire = options.toWire();
      expect(wire.containsKey('androidPrefs'), isFalse);
      expect(wire['appGroupId'], 'group.com.example');
      expect(wire['useGlance'], isTrue);
    });

    test('toWire includes explicit android prefs name', () {
      const options = FlowWidgetOptions(
        androidNamedSharedPreferences: 'flow_widget',
      );
      expect(options.toWire()['androidPrefs'], 'flow_widget');
    });
  });
}
