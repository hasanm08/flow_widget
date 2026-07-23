# Platform setup

## Android

1. Add `flow_widget` to your app.
2. Create an `AppWidgetProvider` / Glance receiver (or run the CLI `create` command).
3. Register the receiver in `AndroidManifest.xml`.
4. Call `FlowWidget.registerConfig` with `androidProviderFullyQualifiedName`.
5. Prefer Glance when `FlowWidgetOptions.useGlance` is true (default) and your
   receiver extends `GlanceAppWidgetReceiver`. With `useGlance: true`,
   `FlowWidget.update` / `updateAll` recomposes Glance via `updateAll` /
   per-id `update` and `ACTION_APPWIDGET_UPDATE` — not only
   `notifyAppWidgetViewDataChanged`.

### SharedPreferences name (easy to mismatch)

Android storage uses a **SharedPreferences file name**, independent of iOS
`appGroupId`:

| Flutter | Native |
| --- | --- |
| `FlowWidgetOptions.androidNamedSharedPreferences` | `FlowWidgetStorage.create(context, prefsName)` |
| `null` → `flutter_flow_widget` | `FlowWidgetStorage.DEFAULT_PREFS_NAME` |

These **must be identical**. If Flutter writes to `flutter_flow_widget` and
your Glance widget reads `"flow_widget"`, the widget will never see updates.

```dart
await FlowWidget.initialize(
  options: const FlowWidgetOptions(
    appGroupId: 'group.com.example.app', // iOS / macOS only
    androidNamedSharedPreferences: 'flutter_flow_widget', // or omit for default
    useGlance: true,
  ),
);
```

```kotlin
val storage = FlowWidgetStorage.create(
    context,
    FlowWidgetStorage.DEFAULT_PREFS_NAME, // must match Flutter
)
```

Minimum SDK: **24**. Target / compile SDK: **35**.

### Glance clicks and Flutter deep linking (`/CALLBACK`)

AndroidX Glance requires unique PendingIntents for `actionStartActivity`.
When your `Intent` has **no** `data`, Glance calls `createUniqueUri` and
`setData`s a trampoline path like:

```text
/CALLBACK?appWidgetId=5&viewId=12&viewSize=…&extraData=
```

If `flutter_deeplinking_enabled` is on, Flutter reads `Intent.data` and
navigates to `/CALLBACK?…` → “Page not found”.

**Fix (preferred):** build the Intent with
`FlowWidgetLaunch.activityIntent(...)` so `data` is already a unique app URI
(`flowwidget://app/<route>`), and extend `FlowWidgetFlutterActivity` from
`MainActivity` to sanitize any leftover `/CALLBACK` and prefer the `route`
extra for `getInitialRoute()`.

```kotlin
actionStartActivity(
    FlowWidgetLaunch.activityIntent(
        context = context,
        activityClass = MainActivity::class.java,
        route = "/dashboard",
        action = "open",
        widgetName = "DemoWidget",
    ),
)
```

```kotlin
class MainActivity : FlowWidgetFlutterActivity()
```

Passing `action` also emits a `click` event on the flow_widget EventChannel
(`FlowWidget.onClicked`) once the activity starts.

## iOS

1. Set **minimum deployment target to iOS 14.0** in `ios/Podfile` and the Runner Xcode project.
2. Enable an **App Group** for the app and widget extension.
3. Pass the group id to `FlowWidget.initialize(options: FlowWidgetOptions(appGroupId: '...'))`.
4. Create a WidgetKit extension (CLI `create` generates starter Swift).
5. Use matching `iosKind` strings in `FlowWidgetConfig` and the extension.
6. For Live Activities, include `FlowWidgetActivityAttributes` (or your generated attributes) in both targets and enable ActivityKit.

Deployment target: **iOS 14.0+** (Live Activities require **16.2+**).
CocoaPods and Swift Package Manager are both supported.

## macOS

1. Set **minimum deployment target to macOS 11.0** in `macos/Podfile` and the Runner Xcode project.
2. Enable an **App Group** for the app and widget extension.

## Windows / Linux

Install the plugin normally. Shared storage and `update*` succeed; visual desktop widgets depend on OS/DE APIs that are limited. See package READMEs for current capabilities and extension points.

## Wear OS

Add `flow_widget_wear` to your app's **Wear module**, extend `FlowWidgetTileService`, and declare the tile service in the Wear manifest.

## watchOS

watchOS does not run the Flutter engine. Use CLI-generated Swift in a Watch extension and share data via App Group. The phone app uses the normal `flow_widget` APIs.
