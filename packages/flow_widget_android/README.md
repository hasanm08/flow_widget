# flow_widget_android

Android federated implementation for [flow_widget](https://github.com/hasanm08/flow_widget).

## Features

- SharedPreferences-backed typed storage with the flow_widget wire codec
- AppWidget / Glance refresh via registered provider class names
  - With `useGlance: true`, refresh recomposes Glance (`updateAll` / per-id
    `update` + `ACTION_APPWIDGET_UPDATE`)
  - With `useGlance: false`, refresh invalidates RemoteViews collections
- Image persistence under `filesDir/flow_widget_images/`
- Pin-widget requests via `AppWidgetManager.requestPinAppWidget` (API 26+)
- `FlowWidgetLaunch` + `FlowWidgetFlutterActivity` helpers so Glance
  `actionStartActivity` does not inject `/CALLBACK` into Flutter deep links
- Live Activities are not supported on Android (methods return `unsupported`)

## SharedPreferences name

Default file name: `flutter_flow_widget`
(`FlowWidgetStorage.DEFAULT_PREFS_NAME`).

Pass the same value from Flutter via
`FlowWidgetOptions.androidNamedSharedPreferences`. Do **not** rely on
`appGroupId` for Android — that option is iOS/macOS only.

## Glance click launches

Glance may overwrite `Intent.data` with `/CALLBACK?…` when the Intent has no
URI. Flutter then deep-links to that path. Prefer:

```kotlin
actionStartActivity(
    FlowWidgetLaunch.activityIntent(
        context,
        MainActivity::class.java,
        route = "/dashboard",
        action = "open",
        widgetName = "DemoWidget",
    ),
)
```

```kotlin
class MainActivity : FlowWidgetFlutterActivity()
```

When `action` is set, `FlowWidgetFlutterActivity` also emits a `click` event
for Dart `FlowWidget.onClicked`.

## Usage

Add `flow_widget` to your app; this package is pulled in automatically as the
default Android implementation.

Register widget providers in your host app manifest and call
`FlowWidget.registerConfig` with `androidProviderFullyQualifiedName` so the
plugin can refresh instances.

## Channel contract

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
