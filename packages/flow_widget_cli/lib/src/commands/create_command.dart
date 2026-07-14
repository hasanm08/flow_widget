/// create command — scaffold native widget templates.
library;

import 'package:flow_widget_cli/src/commands/command_base.dart';
import 'package:flow_widget_cli/src/template_writer.dart';
import 'package:flow_widget_cli/src/validation/name_sanitizer.dart';

class CreateCommand extends FlowWidgetCommand {
  CreateCommand({required super.terminal, required super.context}) {
    argParser
      ..addOption(
        'name',
        abbr: 'n',
        help: 'Widget name in PascalCase (e.g. WeatherWidget).',
        mandatory: true,
      )
      ..addOption(
        'platforms',
        abbr: 'p',
        help: 'Comma-separated platforms: android,ios,macos,windows,linux.',
        defaultsTo: 'android,ios',
      )
      ..addOption(
        'output',
        abbr: 'o',
        help:
            'Output directory relative to project root (default: flow_widget).',
      );
  }

  @override
  final name = 'create';

  @override
  final description = 'Generate widget templates for selected platforms.';

  @override
  Future<int> execute() async {
    requireFlutterProject();

    final widgetName = sanitizeWidgetName(argResults!['name']! as String);
    final platforms = parsePlatforms(argResults!['platforms']! as String);
    final output = argResults!['output'] as String?;

    for (final platform in platforms) {
      if (!supportedPlatforms.contains(platform)) {
        throw FormatException('Unsupported platform "$platform".');
      }
    }

    terminal.heading('Creating $widgetName for ${platforms.join(', ')}');

    final writer = TemplateWriter(context: context, terminal: terminal);
    await writer.writeWidget(
      widgetName: widgetName,
      platforms: platforms,
      outputDir: output,
    );

    terminal.info('');
    terminal.info('Next steps:');
    terminal.info('  1. Run `dart run flow_widget_cli:flow_widget configure`');
    terminal.info('  2. Copy generated snippets into your native projects');
    terminal.info('  3. Run `dart run flow_widget_cli:flow_widget doctor`');

    return 0;
  }
}
