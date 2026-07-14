# flow_widget_cli

Production CLI for scaffolding and validating [flow_widget](https://pub.dev/packages/flow_widget) integrations.

Repository: [github.com/hasanm08/flow_widget](https://github.com/hasanm08/flow_widget)

## Installation

Add as a dev dependency in your Flutter app:

```yaml
dev_dependencies:
  flow_widget_cli:
    path: ../packages/flow_widget_cli # or pub version when published
```

## Usage

Run from your Flutter project root:

```bash
dart run flow_widget_cli:flow_widget <command> [options]
```

Global flag:

- `--verbose` / `-v` — extra logging

## Commands

| Command | Description |
|---------|-------------|
| `create` | Generate native widget templates for selected platforms |
| `configure` | Create or update `flow_widget.yaml` |
| `generate` | Read `flow_widget.yaml` and emit native boilerplate |
| `doctor` | Check Flutter project, dependencies, and native hints |
| `preview` | Print registered widgets from config |
| `clean` | Remove `flow_widget/.generated/` artifacts |
| `validate` | Validate `flow_widget.yaml` schema and naming |

### Examples

```bash
# Scaffold Android + iOS templates
dart run flow_widget_cli:flow_widget create \
  --name WeatherWidget \
  --platforms android,ios

# Write project config
dart run flow_widget_cli:flow_widget configure \
  --app-group-id group.com.example.weather \
  --name WeatherWidget \
  --platforms android,ios,macos

# Regenerate native snippets from config
dart run flow_widget_cli:flow_widget generate

# Validate setup
dart run flow_widget_cli:flow_widget doctor
dart run flow_widget_cli:flow_widget validate
```

Generated files are written under `flow_widget/<WidgetName>/.generated/` with copy-pasteable Kotlin, Swift, XML snippets, and desktop README stubs.

## Exit codes

- `0` — success
- `1` — command failure
- `64` — usage error
