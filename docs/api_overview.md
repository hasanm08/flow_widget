# API overview

Public surface of the `flow_widget` federation. Application code should import
`package:flow_widget/flow_widget.dart` unless noted.

## Core API — `FlowWidget`

Static, process-wide entry point. Call [initialize] once at startup.

| Method / getter | Description |
|-----------------|-------------|
| `initialize({FlowWidgetOptions})` | Bootstraps the plugin and native bridges |
| `getCapabilities()` | Returns platform feature flags |
| `getPlatformType()` | Returns `FlowWidgetPlatformType` |
| `getInstalledWidgets()` | Lists widget instances (platform-dependent) |
| `saveData({key, value, groupId})` | Persists a typed value |
| `save(model)` / `saveBatch({entries})` | Persists code-generated or manual entries |
| `getData` / `getString` / `getInt` / `getBool` | Reads shared storage |
| `getAllData({prefix, groupId})` | Bulk read with optional key prefix |
| `removeData` / `clearData` | Deletes storage keys |
| `saveImage` / `removeImage` | Widget image assets |
| `update({name, id, data})` | Triggers a widget refresh |
| `updateMany` / `updateAll` | Batch refresh |
| `saveAndUpdate(model, {name})` | Save then refresh in one call |
| `setTimeline({name, entries})` | Publishes scheduled timeline snapshots |
| `registerConfig(FlowWidgetConfig)` | Registers widget family metadata |
| `requestPinWidget({name})` | Android pin-widget sheet (API 26+) |
| `events` / `onClicked` / `onConfigured` | Platform event streams |
| `liveActivity` | `LiveActivityController` (iOS) |
| `dispose()` | Releases native resources |

## Live Activities — `LiveActivityController`

iOS-only. Access via `FlowWidget.liveActivity`.

- `start(config)` — begin a Live Activity / Dynamic Island session
- `update(id, state)` — push new content state
- `end(id, {dismissalPolicy})` — end an activity
- `getActive()` — list running activities

## Typed values — `FlowWidgetValue`

Compact `{t, v}` wire codec shared between Dart and native code.

- Factory helpers: `string`, `intValue`, `doubleValue`, `boolValue`, `dateTime`, `json`, `bytes`, `map`, `list`
- `box(Object)` — converts Dart primitives to typed values
- `unbox()` — converts back to Dart objects

## Configuration models

| Type | Purpose |
|------|---------|
| `FlowWidgetOptions` | App-wide settings (App Group id, batching, logging) |
| `FlowWidgetConfig` | Per-widget family registration (Android provider FQCN, iOS kind, …) |
| `FlowWidgetUpdateRequest` | Single update payload |
| `FlowWidgetTimelineEntry` | Scheduled snapshot for timeline providers |
| `FlowWidgetImage` | Local bytes or remote URL for widget images |
| `LiveActivityConfig` / `LiveActivityState` | Live Activity lifecycle |

## Events

| Type | When emitted |
|------|--------------|
| `FlowWidgetClickEvent` | User taps an interactive widget action |
| `FlowWidgetConfiguredEvent` | Widget instance added or reconfigured |
| `FlowWidgetTimelineReloadEvent` | Timeline provider reload signal |
| `FlowWidgetLiveActivityEvent` | Live Activity state changes |

## Code generation

Package: `flow_widget_annotation` + `flow_widget_generator`

| Annotation | Purpose |
|------------|---------|
| `@FlowWidgetModel` | Marks a class for serializer generation |
| `@FlowWidgetKey('key')` | Override storage key for a field |
| `@FlowWidgetIgnore` | Skip a field |

Generated extensions provide `toFlowEntries()` and `fromFlowEntries()`.

## Companion packages

Not pulled in by `flow_widget` automatically:

| Package | Use when |
|---------|----------|
| `flow_widget_wear` | Wear OS Tiles in a Wear module |
| `flow_widget_watchos` | watchOS Complications via App Group + CLI |
| `flow_widget_cli` | Scaffolding native widget targets |
| `flow_widget_generator` | `build_runner` codegen |

## Platform interface

`flow_widget_platform_interface` defines `FlowWidgetPlatform` for custom
implementations. Default packages (`flow_widget_android`, `flow_widget_ios`, …)
register via Flutter's federated plugin mechanism.

## Further reading

- [Architecture](architecture.md)
- [Platform setup](platform_setup.md)
- [Best practices](best_practices.md)
- [Troubleshooting](troubleshooting.md)
