/// clean command — remove generated artifacts.
library;

import 'dart:io';

import 'package:flow_widget_cli/src/commands/command_base.dart';
import 'package:path/path.dart' as p;

class CleanCommand extends FlowWidgetCommand {
  CleanCommand({required super.terminal, required super.context});

  @override
  final name = 'clean';

  @override
  final description = 'Remove generated flow_widget/.generated/ artifacts.';

  @override
  Future<int> execute() async {
    requireFlutterProject();

    final flowWidgetDir = context.flowWidgetDir;
    if (!await flowWidgetDir.exists()) {
      terminal.info('Nothing to clean.');
      return 0;
    }

    var removed = 0;
    await for (final entity in flowWidgetDir.list(recursive: true)) {
      if (entity is Directory && p.basename(entity.path) == '.generated') {
        await entity.delete(recursive: true);
        terminal.verboseLog('Removed ${entity.path}');
        removed++;
      }
    }

    if (removed == 0) {
      terminal.info('Nothing to clean.');
      return 0;
    }

    terminal.success('Removed $removed generated artifact folder(s).');
    return 0;
  }
}
