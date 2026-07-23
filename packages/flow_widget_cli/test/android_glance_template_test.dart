import 'package:flow_widget_cli/src/templates/android_glance.dart';
import 'package:test/test.dart';

void main() {
  group('androidGlanceProvider', () {
    test('uses FlowWidgetLaunch to avoid Glance CALLBACK trampoline', () {
      final source = androidGlanceProvider(
        applicationId: 'com.example.app',
        widgetName: 'DemoWidget',
        packageName: 'dev.flowwidget.widgets',
      );

      expect(source, contains('FlowWidgetLaunch.activityIntent'));
      expect(source, contains('actionStartActivity('));
      expect(source, contains('com.example.app.MainActivity'));
      expect(source, isNot(contains('actionStartActivity<MainActivity>')));
    });
  });

  group('androidMainActivitySnippet', () {
    test('extends FlowWidgetFlutterActivity', () {
      final source = androidMainActivitySnippet(
        applicationId: 'com.example.app',
      );

      expect(source, contains('class MainActivity : FlowWidgetFlutterActivity()'));
      expect(source, contains('package com.example.app'));
    });
  });
}
