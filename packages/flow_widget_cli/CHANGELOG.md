# Changelog

## 1.0.2

- Android Glance templates open the app via `FlowWidgetLaunch.activityIntent`
  (avoids Glance `/CALLBACK` deep-link footgun).
- Generate `MainActivity.kt.snippet` extending `FlowWidgetFlutterActivity`.

## 1.0.1

- Android Glance template uses `FlowWidgetStorage.DEFAULT_PREFS_NAME` so
  generated widgets match the Flutter default prefs file.

## 1.0.0

- Initial stable release.
