/// configure command — write flow_widget.yaml.
library;

import 'package:flow_widget_cli/src/commands/command_base.dart';
import 'package:flow_widget_cli/src/templates/flow_widget_yaml.dart';
import 'package:flow_widget_cli/src/validation/name_sanitizer.dart';

class ConfigureCommand extends FlowWidgetCommand {
  ConfigureCommand({required super.terminal, required super.context}) {
    argParser
      ..addOption('app-group-id', help: 'iOS/macOS App Group identifier.')
      ..addOption('name', abbr: 'n', help: 'Widget name to register.')
      ..addOption(
        'platforms',
        abbr: 'p',
        help: 'Platforms for the widget.',
        defaultsTo: 'android,ios',
      )
      ..addOption('prefix', help: 'Storage key prefix for widget data.');
  }

  @override
  final name = 'configure';

  @override
  final description = 'Create or update flow_widget.yaml in the project root.';

  @override
  Future<int> execute() async {
    requireFlutterProject();

    final existing = await context.readConfig();
    final widgetName = argResults!['name'] as String?;
    final platforms = parsePlatforms(argResults!['platforms']! as String);
    final appGroupId =
        argResults!['app-group-id'] as String? ??
        existing['appGroupId'] as String? ??
        'group.${context.applicationId ?? 'com.example.app'}';
    final prefix = argResults!['prefix'] as String? ?? '';

    final config = Map<String, Object?>.from(existing);
    config['appGroupId'] = appGroupId;
    config['platforms'] = platforms;

    final widgets = List<Map<String, Object?>>.from(
      (config['widgets'] as List?)?.map(
            (w) => Map<String, Object?>.from(w as Map),
          ) ??
          [],
    );

    if (widgetName != null) {
      final name = sanitizeWidgetName(widgetName);
      widgets.removeWhere((w) => w['name'] == name);
      widgets.add({
        'name': name,
        if (prefix.isNotEmpty) 'prefix': prefix,
        'platforms': platforms,
      });
    } else if (widgets.isEmpty) {
      config.addAll(
        defaultFlowWidgetConfig(
          widgetName: 'ExampleWidget',
          platforms: platforms,
          appGroupId: appGroupId,
        ),
      );
      await context.writeConfig(config);
      terminal.success('Created flow_widget.yaml with defaults.');
      return 0;
    }

    config['widgets'] = widgets;
    await context.writeConfig(config);
    terminal.success('Updated ${context.configFile.path}');
    return 0;
  }
}
