# Migration guide

## From `home_widget`

| home_widget | flow_widget |
|-------------|-------------|
| `HomeWidget.saveWidgetData(key, value)` | `FlowWidget.saveData(key: key, value: value)` |
| `HomeWidget.updateWidget(name: ...)` | `FlowWidget.update(name: ...)` |
| `HomeWidget.widgetClicked` | `FlowWidget.onClicked` |
| App Group set via method | `FlowWidgetOptions(appGroupId: ...)` at initialize |

### Steps

1. Replace the dependency with `flow_widget: ^1.0.0`.
2. Call `await FlowWidget.initialize(...)` once in `main`.
3. Migrate save/update call sites (named parameters).
4. Regenerate native glue with `flow_widget_cli` if needed.
5. Prefer `@FlowWidgetModel` + codegen instead of ad-hoc string keys.

## From custom MethodChannels

Map your channel methods onto the documented `dev.flow_widget/methods` contract or keep a thin adapter that calls `FlowWidgetPlatform.instance`.
