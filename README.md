# flow_widget

Production-ready Flutter plugin for home-screen widgets, Live Activities, Wear OS Tiles, and watchOS Complications — one Dart API across platforms.

[![CI](https://github.com/hasanm08/flow_widget/actions/workflows/ci.yml/badge.svg)](https://github.com/hasanm08/flow_widget/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/flow_widget.svg)](https://pub.dev/packages/flow_widget)

## Why flow_widget?

Existing home-widget packages tend to be stringly typed, tightly coupled to a single platform, or difficult to maintain at enterprise scale. **flow_widget** is built as a federated plugin with:

- A minimal, strongly typed Dart API
- Batched MethodChannel traffic and a compact wire codec
- First-class Android (App Widgets + Glance), iOS (WidgetKit + Live Activities), macOS, Windows, Linux, Wear OS, and watchOS support
- CLI scaffolding and `build_runner` code generation
- Strict analysis, comprehensive tests, and CI

## Quick start

```yaml
dependencies:
  flow_widget: ^1.0.0
```

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

### Typed models

```dart
@FlowWidgetModel(prefix: 'user_')
class UserWidgetData {
  const UserWidgetData({
    required this.name,
    required this.score,
  });

  final String name;
  final int score;
}

// After build_runner:
await FlowWidget.saveBatch(entries: user.toFlowEntries());
await FlowWidget.update(name: 'ProfileWidget');
```

## Architecture

```
flow_widget/                          # App-facing API
flow_widget_platform_interface/       # Shared contract + codec
flow_widget_android/                  # App Widgets + Glance
flow_widget_ios/                      # WidgetKit + Live Activities
flow_widget_macos/                    # Desktop WidgetKit
flow_widget_windows/                  # Storage bridge (OS-limited)
flow_widget_linux/                    # Storage bridge (DE-limited)
flow_widget_wear/                     # Wear OS Tiles companion
flow_widget_watchos/                  # Complication bridge + Swift helpers
flow_widget_cli/                      # Scaffolding & doctor
flow_widget_annotation/               # @FlowWidgetModel
flow_widget_generator/                # build_runner codegen
```

Never mix platform implementations — each package is independently versioned and testable.

## CLI

```bash
dart run flow_widget_cli:flow_widget create --name WeatherWidget --platforms android,ios
dart run flow_widget_cli:flow_widget configure --app-group-id group.com.example.app
dart run flow_widget_cli:flow_widget doctor
dart run flow_widget_cli:flow_widget validate
```

## Platform support

| Feature | Android | iOS | macOS | Windows | Linux | Wear | watchOS |
|---------|---------|-----|-------|---------|-------|------|---------|
| Home widgets | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | — | — |
| Lock screen | ✅ | ✅ | — | — | — | — | — |
| Interactive | ✅ | ✅ | ✅ | — | — | ✅ | ✅ |
| Timeline | ✅ Glance | ✅ | ✅ | — | — | periodic | — |
| Live Activities / Island | — | ✅ | — | — | — | — | — |
| Tiles / Complications | — | — | — | — | — | ✅ | ✅ |
| Shared storage | ✅ | App Group | App Group | file | file | ✅ | App Group |

⚠️ Windows and Linux expose shared storage and update hooks. OS-level visual widgets depend on public APIs that are limited or DE-specific — see platform READMEs.

## Documentation

| Guide | Description |
|-------|-------------|
| [API overview](docs/api_overview.md) | Public API summary |
| [Architecture](docs/architecture.md) | Federated design & channel contract |
| [Platform setup](docs/platform_setup.md) | Android, iOS, macOS, Wear, watchOS |
| [Migration](docs/migration.md) | From `home_widget` / similar packages |
| [Performance](docs/performance.md) | Batching, codec, image cache |
| [Best practices](docs/best_practices.md) | API usage patterns |
| [Troubleshooting](docs/troubleshooting.md) | Common issues |
| [FAQ](docs/faq.md) | Frequent questions |
| [Contributing](docs/contributing.md) | Dev workflow |

## Example

The `example/` app demonstrates weather, habits, calendar, fitness, music, finance, news, photos, countdown, interactive checklists, and Live Activities.

```bash
cd example && flutter run
```

## License

MIT — see [LICENSE](LICENSE).
