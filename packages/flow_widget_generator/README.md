# flow_widget_generator

`build_runner` code generator for `@FlowWidgetModel` annotated classes.

Pair with:

- `package:flow_widget_annotation` — annotations
- `package:flow_widget` — runtime save/load API

## Setup

```yaml
dependencies:
  flow_widget_annotation: ^1.0.0
  flow_widget_platform_interface: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.13
  flow_widget_generator: ^1.0.0
```

## Usage

```dart
import 'package:flow_widget_annotation/flow_widget_annotation.dart';

part 'dashboard_data.flow_widget.g.dart';

@FlowWidgetModel(prefix: 'dashboard_')
class DashboardData {
  const DashboardData({required this.score, required this.title});
  final int score;
  final String title;
}
```

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Generated API

The generator emits an extension on your model using `flow_widget_platform_interface` types only (no Flutter dependency in generated code):

```dart
extension $DashboardDataFlowWidget on DashboardData {
  List<FlowWidgetDataEntry> toFlowEntries() => [
    FlowWidgetDataEntry(
      key: 'dashboard_score',
      value: FlowWidgetValue.intValue(score),
    ),
    FlowWidgetDataEntry(
      key: 'dashboard_title',
      value: FlowWidgetValue.string(title),
    ),
  ];

  static DashboardData? fromFlowEntries(Map<String, FlowWidgetValue> data) {
    final score = data['dashboard_score']?.unbox() as int?;
    final title = data['dashboard_title']?.unbox() as String?;
    return DashboardData(score: score!, title: title!);
  }
}
```

Persist from your app:

```dart
import 'package:flow_widget/flow_widget.dart';

await FlowWidget.saveBatch(entries: dashboard.toFlowEntries());
```

### Storage key mode

Use `@FlowWidgetModel(storageKey: 'dashboard_blob')` to store the entire model as one JSON value.

### Supported field types

- `String`, `int`, `double`, `bool`, `DateTime`
- `List` / `Map` (limited — boxed via `FlowWidgetValue.box`)
- Enums (stored as `.name` strings)

Fields annotated with `@FlowWidgetIgnore` are skipped. Use `@FlowWidgetKey('custom_key')` to override storage keys.

## build.yaml

The builder is registered as `flow_widget_generator|flow_widget` and auto-applies to dependents.
