import 'dart:io';

import 'package:flow_widget_cli/flow_widget_cli.dart';

Future<void> main(List<String> arguments) async {
  final exitCode = await FlowWidgetCliRunner().run(arguments);
  exit(exitCode);
}
