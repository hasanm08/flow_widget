# Troubleshooting

## Pod install fails on iOS (deployment target)

If you see:

> The plugin "flow_widget_ios" requires a higher minimum iOS deployment version

Set your app to **iOS 14.0+**:

- `ios/Podfile`: `platform :ios, '14.0'`
- Xcode Runner target → Minimum Deployments → **14.0**

Then run:

```bash
cd ios && pod install --repo-update
```

## Pod install fails on macOS (deployment target)

If you see:

> The plugin "flow_widget_macos" requires a higher minimum macOS deployment version

Set your app to **macOS 11.0+**:

- `macos/Podfile`: `platform :osx, '11.0'`
- Xcode Runner target → Minimum Deployments → **11.0**

Then run:

```bash
cd macos && pod install --repo-update
```

## Widget does not update

- Confirm `FlowWidget.initialize` succeeded
- Verify `registerConfig` provider / kind matches the native target
- On iOS, ensure App Group entitlements match `appGroupId`
- On Android, confirm the receiver is exported and listed in the manifest
- On Android Glance: ensure `useGlance: true` (default) so refresh calls Glance
  `updateAll` / `ACTION_APPWIDGET_UPDATE`, not only RemoteViews invalidation
- On Android: ensure `androidNamedSharedPreferences` matches the name passed to
  `FlowWidgetStorage.create` in Kotlin (default: `flutter_flow_widget`).
  `appGroupId` is **not** used as the Android prefs name

## Android SharedPreferences mismatch

Symptoms: Flutter `saveData` / `update` succeed, but the home-screen widget
still shows placeholders or stale values.

Cause: Flutter and native code opened different prefs files (for example
Flutter default `flutter_flow_widget` vs Kotlin `"flow_widget"`).

Fix: use the same string on both sides, or omit the Flutter option and use
`FlowWidgetStorage.DEFAULT_PREFS_NAME` in Kotlin.

## Android Glance opens `/CALLBACK` (“Page not found”)

Symptoms: tapping a Glance widget launches the app on a `/CALLBACK?…` route.

Cause: Glance overwrote `Intent.data` with its trampoline URI because the
start-activity Intent had no `data`. Flutter deep linking navigated there.

Fix: use `FlowWidgetLaunch.activityIntent` and
`FlowWidgetFlutterActivity` (see [Platform setup](platform_setup.md) and
[FAQ](faq.md)).

## `FlowWidgetNotInitializedException`

Call `initialize` before any other API.

## Live Activities fail

Requires iOS 16.2+, ActivityKit capability, and matching attributes in the extension. On other platforms expect `unsupported`.

## Images missing in widgets

Save via `FlowWidget.saveImage` into the App Group / shared files dir. Remote URLs need network permission in the extension.

## `doctor` reports failures

Run `dart run flow_widget_cli:flow_widget doctor --verbose` and fix the first red item (usually missing dependency or App Group).
