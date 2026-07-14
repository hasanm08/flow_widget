/// Desktop platform stub templates.
library;

String desktopReadme({required String platform, required String widgetName}) {
  return '''
# $widgetName on $platform

The flow_widget plugin stores widget data locally on $platform using shared
preferences / registry keys. Native home-screen widgets are not supported on
$platform yet.

## Storage keys

Use these keys when calling `FlowWidget.saveData` or generated model serializers:

- `${widgetName.toLowerCase()}_title` — primary label
- `${widgetName.toLowerCase()}_body` — secondary text

## Next steps

1. Ensure `flow_widget` is initialized in your Flutter app.
2. Persist data from Dart; the $platform plugin keeps values in local storage.
3. Re-run `dart run flow_widget_cli:flow_widget doctor` to verify setup.
''';
}

String desktopStorageConstants({required String widgetName}) {
  return '''
/// Storage keys for $widgetName on desktop platforms.
abstract final class ${widgetName}StorageKeys {
  static const title = '${widgetName.toLowerCase()}_title';
  static const body = '${widgetName.toLowerCase()}_body';
}
''';
}
