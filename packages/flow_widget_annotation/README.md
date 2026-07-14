# flow_widget_annotation

Annotations for [flow_widget](https://pub.dev/packages/flow_widget) code generation.

Pair this package with `flow_widget_generator` and `build_runner` to generate typed
`toFlowEntries()` / `fromFlowEntries()` serializers for widget data models.

## Annotations

| Annotation | Purpose |
|------------|---------|
| `@FlowWidgetModel` | Marks a class for code generation |
| `@FlowWidgetKey('custom')` | Overrides the storage key for a field |
| `@FlowWidgetIgnore` | Excludes a field from generated serializers |

## Setup

```yaml
dependencies:
  flow_widget_annotation: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.13
  flow_widget_generator: ^1.0.0
```

See [flow_widget_generator](../flow_widget_generator) for usage examples.

## License

MIT — see [LICENSE](LICENSE).
