# flow_widget_macos

macOS federated implementation of [flow_widget](https://github.com/hasanm08/flow_widget).

## Requirements

- **macOS 11.0 (Big Sur) or later** — WidgetKit desktop widgets require macOS 11+.
- Set your app's deployment target to at least **11.0**:

```ruby
# macos/Podfile
platform :osx, '11.0'
```

In Xcode: Runner target → General → Minimum Deployments → macOS **11.0**.

See [Flutter macOS deployment](https://docs.flutter.dev/deployment/macos#update-the-minimum-target-platform-version).

## Capabilities

| Feature | Supported |
| --- | --- |
| Home screen widgets (WidgetKit) | Yes |
| Interactive widgets | Yes |
| Timeline providers | Yes |
| App Groups shared storage | Yes |
| Live Activities / Dynamic Island | No |
| Pin widget UI | No |
| Remote image caching | No (bytes only) |

## Setup

1. Add an App Group capability to both the Runner target and the Widget Extension.
2. Pass the group id when initializing flow_widget:

```dart
await FlowWidget.initialize(
  FlowWidgetOptions(appGroupId: 'group.dev.flowwidget'),
);
```

3. Register widget kinds with `registerConfig` and reload timelines via `update`.

## Storage

Typed values are stored in `UserDefaults(suiteName: appGroupId)` using the
`{t, v}` wire format defined by `flow_widget_platform_interface`. Widget
extensions read the same store.

## Limitations

- **Live Activities** are iOS-only; all Live Activity methods return
  `unsupported` on macOS.
- **requestPinWidget** always returns `false` — macOS does not expose a public
  pin/add-widget sheet from third-party apps.
- **getInstalledWidgets** returns an empty list; WidgetKit does not expose
  installed-instance metadata to host apps.
- **Remote images** (`FlowWidgetImage.remote`) are not cached natively; pass
  bytes from Dart or download in the widget extension.

## Channels

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
