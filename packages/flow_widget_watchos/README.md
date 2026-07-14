# flow_widget_watchos

watchOS Complications bridge for
[flow_widget](https://github.com/hasanm08/flow_widget).

## Architecture

watchOS apps are **native Watch extensions** — Flutter does not run on Apple
Watch. The data flow is:

```
Flutter (iOS host)  →  App Group storage  →  Watch extension  →  Complications
```

1. The paired iPhone app uses `FlowWidgetWatchOs` (or `flow_widget_ios`) to
   persist typed `{t, v}` values into a shared App Group.
2. `flow_widget_cli` generates a Watch extension target that compiles the Swift
   sources from `watchos/` in this package.
3. Complication controllers read `FlowWidgetStorage` and reload via
   `FlowWidgetComplicationController`.

## Capabilities

| Feature | Supported |
| --- | --- |
| Complications | Yes |
| Home widgets | No |
| Live Activities | No |
| Direct Flutter on watchOS | No |

## Dart usage

```dart
import 'package:flow_widget_watchos/flow_widget_watchos.dart';

// Optional: register when building a watch-aware iOS host.
FlowWidgetWatchOs.registerWith();

await FlowWidget.saveData(
  key: 'complication.weather',
  value: FlowWidgetValue.string('72°F'),
  groupId: 'group.dev.flowwidget',
);
```

`getPlatformType` returns `"watchOs"` when the native bridge handles channel
calls from a watch-aware host build.

## Swift integration (CLI-generated)

Copy or generate these files into the Watch extension:

- `FlowWidgetValueCodec.swift`
- `FlowWidgetStorage.swift`
- `FlowWidgetComplicationController.swift`
- `FlowWidgetWatchBridge.swift`

In the Watch extension delegate:

```swift
FlowWidgetWatchBridge.handleDataUpdate(appGroupId: "group.dev.flowwidget")
```

## Limitations

- No MethodChannel on watchOS itself — communication is via App Group + optional
  `WCSession` ping.
- Complication UI must be implemented in native Swift/SwiftUI in the Watch
  extension; this package provides storage and reload helpers only.

## Channels

When used from the iOS host with a watch bridge embedded:

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
