# Architecture

flow_widget is a **federated Flutter plugin**. The app-facing package never contains native code; each OS lives in its own package that implements `FlowWidgetPlatform`.

## Packages

| Package | Role |
|---------|------|
| `flow_widget` | Public Dart API developers import |
| `flow_widget_platform_interface` | Abstract platform contract, models, codec, default method channel |
| `flow_widget_*` | Native / desktop / wearable implementations |
| `flow_widget_cli` | Project scaffolding and validation |
| `flow_widget_annotation` + `flow_widget_generator` | Typed model codegen |

## Channel contract

Stable public channels (major-version locked):

- MethodChannel: `dev.flow_widget/methods`
- EventChannel: `dev.flow_widget/events`

Values travel as compact maps:

```json
{ "t": "s", "v": "Amir" }
{ "t": "i", "v": 95 }
{ "t": "dt", "v": 1720000000000 }
```

Batch methods (`saveBatch`, `updateMany`) reduce round-trips on Wear / watchOS.

## Design principles

1. **Composition over inheritance** — sealed value types, immutable models
2. **No reflection** — explicit codecs and generated serializers
3. **Lazy init** — native work starts only after `FlowWidget.initialize`
4. **Fail clearly** — typed exceptions with stable `code` strings
5. **Platform honesty** — unsupported OS APIs throw `FlowWidgetUnsupportedException` or no-op with documented capabilities
