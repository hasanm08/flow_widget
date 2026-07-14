# flow_widget

Cross-platform Flutter plugin for home-screen widgets, Live Activities, and shared widget storage.

[![pub package](https://img.shields.io/pub/v/flow_widget.svg)](https://pub.dev/packages/flow_widget)

## Installation

```yaml
dependencies:
  flow_widget: ^1.0.0
```

Optional companion packages (add manually when needed):

```yaml
dependencies:
  flow_widget_wear: ^1.0.0      # Wear OS Tiles module
  flow_widget_watchos: ^1.0.0  # watchOS Complications bridge
```

## Quick start

```dart
import 'package:flow_widget/flow_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlowWidget.initialize(
    options: const FlowWidgetOptions(
      appGroupId: 'group.com.example.app',
    ),
  );

  await FlowWidget.saveData(key: 'username', value: 'Amir');
  await FlowWidget.update(name: 'ProfileWidget');

  FlowWidget.onClicked.listen((event) {
    debugPrint('Clicked ${event.widgetId} action=${event.action}');
  });

  runApp(const MyApp());
}
```

## Typed models

Use `@FlowWidgetModel` with `flow_widget_generator` for strongly typed save/load:

```dart
@FlowWidgetModel(prefix: 'user_')
class UserWidgetData {
  const UserWidgetData({required this.name, required this.score});
  final String name;
  final int score;
}

// After build_runner:
await FlowWidget.saveBatch(entries: user.toFlowEntries());
await FlowWidget.update(name: 'ProfileWidget');
```

## Documentation

Full guides live in the [repository docs](https://github.com/hasanm08/flow_widget/tree/main/docs):

- [API overview](../../docs/api_overview.md)
- [Architecture](../../docs/architecture.md)
- [Platform setup](../../docs/platform_setup.md)
- [CLI](../flow_widget_cli)

## License

MIT — see [LICENSE](LICENSE).
