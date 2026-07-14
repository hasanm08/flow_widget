/// preview command — show registered widgets.
library;

import 'package:flow_widget_cli/src/commands/command_base.dart';

class PreviewCommand extends FlowWidgetCommand {
  PreviewCommand({required super.terminal, required super.context});

  @override
  final name = 'preview';

  @override
  final description = 'Print a text preview of registered widgets.';

  @override
  Future<int> execute() async {
    requireFlutterProject();

    if (!await context.configFile.exists()) {
      throw StateError('No flow_widget.yaml found.');
    }

    final config = await context.readConfig();
    terminal.heading('flow_widget preview');
    terminal.info('App Group: ${config['appGroupId'] ?? '(not set)'}');
    terminal.info(
      'Platforms: ${(config['platforms'] as List?)?.join(', ') ?? '(none)'}',
    );
    terminal.info('');

    final widgets = config['widgets'] as List?;
    if (widgets == null || widgets.isEmpty) {
      terminal.warn('No widgets registered.');
      return 0;
    }

    for (final widget in widgets) {
      if (widget is! Map) continue;
      final name = widget['name']?.toString() ?? '(unnamed)';
      final prefix = widget['prefix']?.toString() ?? '';
      final platforms = (widget['platforms'] as List?)?.join(', ') ?? 'default';
      terminal.info('• $name');
      terminal.dim('  prefix: ${prefix.isEmpty ? '(none)' : prefix}');
      terminal.dim('  platforms: $platforms');
    }

    return 0;
  }
}
