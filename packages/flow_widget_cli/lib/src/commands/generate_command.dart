/// generate command — emit native boilerplate from flow_widget.yaml.
library;

import 'package:flow_widget_cli/src/commands/command_base.dart';
import 'package:flow_widget_cli/src/template_writer.dart';

class GenerateCommand extends FlowWidgetCommand {
  GenerateCommand({required super.terminal, required super.context}) {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing generated files.',
      negatable: false,
    );
  }

  @override
  final name = 'generate';

  @override
  final description =
      'Read flow_widget.yaml and emit/update native boilerplate.';

  @override
  Future<int> execute() async {
    requireFlutterProject();

    if (!await context.configFile.exists()) {
      throw StateError(
        'Missing flow_widget.yaml. Run `configure` or `create` first.',
      );
    }

    final config = await context.readConfig();
    final widgets = config['widgets'] as List?;
    if (widgets == null || widgets.isEmpty) {
      throw StateError('No widgets defined in flow_widget.yaml.');
    }

    final writer = TemplateWriter(context: context, terminal: terminal);
    for (final widget in widgets) {
      if (widget is! Map) continue;
      final name = widget['name'] as String?;
      if (name == null) continue;
      final platforms =
          (widget['platforms'] as List?)
              ?.map((p) => p.toString().toLowerCase())
              .toList() ??
          (config['platforms'] as List?)
              ?.map((p) => p.toString().toLowerCase())
              .toList() ??
          ['android', 'ios'];
      terminal.heading('Generating $name');
      await writer.writeWidget(widgetName: name, platforms: platforms);
    }

    terminal.success('Generation complete.');
    return 0;
  }
}
