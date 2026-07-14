/// validate command — validate flow_widget.yaml schema.
library;

import 'dart:io';

import 'package:flow_widget_cli/src/commands/command_base.dart';
import 'package:flow_widget_cli/src/validation/yaml_validator.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class ValidateCommand extends FlowWidgetCommand {
  ValidateCommand({required super.terminal, required super.context}) {
    argParser.addOption(
      'file',
      abbr: 'f',
      help: 'Path to flow_widget.yaml (default: project root).',
    );
  }

  @override
  final name = 'validate';

  @override
  final description = 'Validate flow_widget.yaml schema and widget naming.';

  @override
  Future<int> execute() async {
    final filePath = argResults!['file'] as String?;
    final yamlFile = filePath != null
        ? File(p.join(context.root.path, filePath))
        : context.configFile;

    if (!await yamlFile.exists()) {
      throw StateError('File not found: ${yamlFile.path}');
    }

    final doc = loadYaml(await yamlFile.readAsString());
    if (doc is! YamlMap) {
      throw FormatException('Root document must be a YAML map.');
    }

    final result = validateFlowWidgetYaml(doc);
    terminal.heading('Validating ${yamlFile.path}');

    for (final warning in result.warnings) {
      terminal.warn(warning);
    }
    for (final error in result.errors) {
      terminal.error(error);
    }

    if (result.isValid) {
      terminal.success('Validation passed.');
      return 0;
    }

    return 1;
  }
}
