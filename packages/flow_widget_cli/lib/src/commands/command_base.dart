/// Base class for flow_widget CLI commands.
library;

import 'package:args/command_runner.dart';
import 'package:flow_widget_cli/src/project_context.dart';
import 'package:flow_widget_cli/src/terminal.dart';

abstract class FlowWidgetCommand extends Command<int> {
  FlowWidgetCommand({required this.terminal, required this.context});

  final Terminal terminal;
  final ProjectContext context;

  @override
  Future<int> run() async {
    try {
      return await execute();
    } on FormatException catch (e) {
      terminal.error(e.message);
      return 1;
    } on StateError catch (e) {
      terminal.error(e.message);
      return 1;
    } catch (e) {
      terminal.error('$e');
      if (terminal.verbose) {
        terminal.dim(StackTrace.current.toString());
      }
      return 1;
    }
  }

  Future<int> execute();

  void requireFlutterProject() {
    if (!context.isFlutterProject) {
      throw StateError(
        'Not a Flutter project. Run this command from your app root '
        '(directory containing pubspec.yaml with a flutter: section).',
      );
    }
  }
}
