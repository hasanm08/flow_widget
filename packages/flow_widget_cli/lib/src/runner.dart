/// Main CLI runner.
library;

import 'package:args/command_runner.dart';
import 'package:flow_widget_cli/src/commands/clean_command.dart';
import 'package:flow_widget_cli/src/commands/configure_command.dart';
import 'package:flow_widget_cli/src/commands/create_command.dart';
import 'package:flow_widget_cli/src/commands/doctor_command.dart';
import 'package:flow_widget_cli/src/commands/generate_command.dart';
import 'package:flow_widget_cli/src/commands/preview_command.dart';
import 'package:flow_widget_cli/src/commands/validate_command.dart';
import 'package:flow_widget_cli/src/project_context.dart';
import 'package:flow_widget_cli/src/terminal.dart';

/// Parses arguments and dispatches flow_widget CLI commands.
class FlowWidgetCliRunner {
  /// Creates a runner with optional default working directory.
  FlowWidgetCliRunner({this.workingDirectory});

  /// Override for tests.
  final String? workingDirectory;

  /// Runs the CLI and returns an exit code.
  Future<int> run(List<String> arguments) async {
    final verbose = arguments.contains('--verbose');
    final terminal = Terminal(verbose: verbose);
    final filteredArgs = arguments.where((a) => a != '--verbose').toList();

    final context = await ProjectContext.discover(cwd: workingDirectory);

    final runner =
        CommandRunner<int>(
            'flow_widget',
            'Scaffold and validate flow_widget integrations.',
          )
          ..argParser.addFlag(
            'verbose',
            abbr: 'v',
            help: 'Enable verbose logging.',
            negatable: false,
          );

    runner
      ..addCommand(CreateCommand(terminal: terminal, context: context))
      ..addCommand(ConfigureCommand(terminal: terminal, context: context))
      ..addCommand(GenerateCommand(terminal: terminal, context: context))
      ..addCommand(DoctorCommand(terminal: terminal, context: context))
      ..addCommand(PreviewCommand(terminal: terminal, context: context))
      ..addCommand(CleanCommand(terminal: terminal, context: context))
      ..addCommand(ValidateCommand(terminal: terminal, context: context));

    try {
      return await runner.run(filteredArgs) ?? 0;
    } on UsageException catch (e) {
      terminal.error(e.message);
      return 64;
    }
  }
}
