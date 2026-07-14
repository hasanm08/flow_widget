# flow_widget_windows

Windows federated implementation of [flow_widget](https://github.com/hasanm08/flow_widget).

## Platform limitations

Windows does **not** expose a stable, public home-screen widget API comparable to
WidgetKit or Android App Widgets. The Windows Widgets platform (powered by
third-party feeds) is not available to arbitrary Flutter desktop apps.

This package therefore provides:

- **Local typed storage** persisted to `%APPDATA%/flow_widget/storage.json`
- **No-op widget updates** that stamp `last_update` after saving data
- **Image bytes** saved under `%APPDATA%/flow_widget/images/`

`update`, `updateMany`, and `updateAll` succeed after persisting data so Dart
callers can share code with mobile platforms without special-casing Windows.

## Capabilities

| Feature | Supported |
| --- | --- |
| Visual desktop widgets | No |
| Background storage | Yes |
| Multiple widget instances | No |
| Live Activities | No |
| App Groups | No |

## Storage layout

```
%APPDATA%/flow_widget/
  storage.json      # typed `{t, v}` values, configs, timelines
  images/           # binary widget images keyed by filename
```

## Future integration

When a supported Windows widget host API becomes available, a native backend can
read the same JSON store without breaking the Dart contract.

## Channels

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
