# flow_widget_linux

Linux federated implementation of [flow_widget](https://github.com/hasanm08/flow_widget).

## Platform limitations

Linux desktop widgets are **desktop-environment specific**. There is no single
public API comparable to WidgetKit or Android App Widgets:

- **GNOME** — Shell extensions (JavaScript / GJS)
- **KDE** — Plasmoids (QML)
- **Others** — Custom panel applets

This package provides **typed local storage** at
`$XDG_CONFIG_HOME/flow_widget/storage.json` (or `~/.config/flow_widget/`).
`update` succeeds as a no-op after saving data and stamping `last_update`.

## Capabilities

| Feature | Supported |
| --- | --- |
| Visual desktop widgets | No (DE-specific) |
| Background storage | Yes |
| Multiple widget instances | No |
| Live Activities | No |

## Extension point architecture

Future desktop-environment backends can be added **without breaking changes**:

1. **Storage contract** — All backends read the same JSON store and `{t, v}` wire
   values defined by `flow_widget_platform_interface`.
2. **Backend interface** — A `FlowWidgetDesktopBackend` (planned in CLI) can be
   implemented per DE:
   - `GnomeShellExtensionBackend` — D-Bus to a GNOME extension
   - `KdePlasmoidBackend` — broadcasts to installed plasmoids
3. **Registration** — Host apps opt in via `FlowWidgetOptions` and generated
   native artifacts from `flow_widget_cli`.

The Dart MethodChannel contract remains stable; only native refresh mechanisms
differ per backend.

## Storage layout

```
$XDG_CONFIG_HOME/flow_widget/
  storage.json
  images/
```

## Channels

- Method channel: `dev.flow_widget/methods`
- Event channel: `dev.flow_widget/events`
