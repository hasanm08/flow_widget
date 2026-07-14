# flow_widget_platform_interface

Common platform interface for the [flow_widget](https://pub.dev/packages/flow_widget) federated plugin.

Application code should depend on `package:flow_widget/flow_widget.dart`. Import
this package only when authoring a custom platform implementation or when
generating code that must avoid a Flutter dependency.

## What this package defines

- **`FlowWidgetPlatform`** — abstract contract every platform plugin implements
- **`FlowWidgetValue`** — typed wire codec (`{t, v}`) for shared storage
- **Models** — `FlowWidgetConfig`, `FlowWidgetOptions`, `FlowWidgetUpdateRequest`, timeline entries, Live Activity config, images, capabilities
- **Events** — click, configuration, timeline reload, Live Activity streams
- **Exceptions** — typed failures for unsupported features and storage errors

## Platform implementations

| Package | Platform |
|---------|----------|
| `flow_widget_android` | Android App Widgets + Glance |
| `flow_widget_ios` | iOS WidgetKit + Live Activities |
| `flow_widget_macos` | macOS WidgetKit |
| `flow_widget_windows` | Windows storage bridge |
| `flow_widget_linux` | Linux storage bridge |
| `flow_widget_wear` | Wear OS Tiles (companion) |
| `flow_widget_watchos` | watchOS Complications (companion) |

## Channel contract

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`

## License

MIT — see [LICENSE](LICENSE).
