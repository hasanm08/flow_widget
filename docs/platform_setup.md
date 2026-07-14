# Platform setup

## Android

1. Add `flow_widget` to your app.
2. Create an `AppWidgetProvider` / Glance receiver (or run the CLI `create` command).
3. Register the receiver in `AndroidManifest.xml`.
4. Call `FlowWidget.registerConfig` with `androidProviderFullyQualifiedName`.
5. Prefer Glance when `FlowWidgetOptions.useGlance` is true and your receiver extends Glance.

Minimum SDK: **24**. Target / compile SDK: **35**.

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

Add `flow_widget_wear` to your **Wear module**, extend `FlowWidgetTileService`, and declare the tile service in the Wear manifest.

## watchOS

watchOS does not run the Flutter engine. Use CLI-generated Swift in a Watch extension and share data via App Group. The phone app uses the normal `flow_widget` APIs.
