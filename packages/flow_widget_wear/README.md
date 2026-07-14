# flow_widget_wear

Wear OS Tiles federated implementation of
[flow_widget](https://github.com/hasanm08/flow_widget).

## Requirements

The **host app must include a Wear OS module**. This package provides the
MethodChannel bridge, typed storage, and tile update triggers — not the full
tile UI.

1. Add `flow_widget_wear` as a dependency.
2. Create a Wear module with a `TileService` extending
   `FlowWidgetTileService`.
3. Register the service in the Wear module `AndroidManifest.xml`.
4. Pass the fully-qualified service class via `registerConfig`:

```dart
await FlowWidget.registerConfig(
  FlowWidgetConfig(
    name: 'StatsTile',
    displayName: 'Stats',
    androidProviderFullyQualifiedName:
        'com.example.wear.StatsTileService',
  ),
);
```

## Capabilities

| Feature | Supported |
| --- | --- |
| Wear OS Tiles | Yes |
| Home widgets | No |
| Scheduled updates | Yes |
| Live Activities | No |

## Tile updates

`update`, `updateMany`, and `updateAll` persist data then call
`TileService.getUpdater(context).requestUpdate(...)` for registered tile
service classes.

## Abstract base class

Extend `FlowWidgetTileService` and implement `buildTileLayout()` using
`androidx.wear.protolayout` to render stored `{t, v}` values.

## Channels

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
- `getPlatformType` returns `"wearOs"`
