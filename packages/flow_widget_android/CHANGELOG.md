# Changelog

## 1.0.3

- Add `FlowWidgetLaunch.activityIntent` so Glance `actionStartActivity`
  Intents carry a unique URI and Glance does not inject `/CALLBACK`.
- Add `FlowWidgetFlutterActivity` to sanitize leftover CALLBACK URIs, prefer
  the `route` extra for `getInitialRoute()`, and emit `click` events when
  `flow_widget_action` is present.
- Expose `FlowWidgetPlugin.emitClick` for EventChannel / Dart `onClicked`.

## 1.0.2

- Glance refresh: when `useGlance` is true, call Glance `updateAll` / per-id
  `update` and send `ACTION_APPWIDGET_UPDATE` instead of relying only on
  `notifyAppWidgetViewDataChanged` (which does not recompose Glance).
- Stop using `appGroupId` as the Android SharedPreferences name fallback;
  default is `FlowWidgetStorage.DEFAULT_PREFS_NAME` (`flutter_flow_widget`).
- Log a warning when `appGroupId` is set but `androidNamedSharedPreferences`
  is null, so prefs mismatches are visible.

## 1.0.1

- Migrate Android Gradle build to AGP 9 / Gradle 9 compatibility.
- Remove pinned AGP 8.7.3 buildscript; use host app toolchain.
- Adopt built-in Kotlin on AGP 9+ with legacy KGP fallback for AGP 8.x.

## 1.0.0

- Initial stable release.
