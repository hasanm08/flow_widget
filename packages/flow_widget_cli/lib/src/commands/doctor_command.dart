/// doctor command — validate project setup.
library;

import 'dart:io';

import 'package:flow_widget_cli/src/commands/command_base.dart';
import 'package:path/path.dart' as p;

class DoctorCommand extends FlowWidgetCommand {
  DoctorCommand({required super.terminal, required super.context});

  @override
  final name = 'doctor';

  @override
  final description = 'Check Flutter project and flow_widget integration.';

  @override
  Future<int> execute() async {
    terminal.heading('flow_widget doctor');

    var failures = 0;

    terminal.checklist(
      ok: context.isFlutterProject,
      message: 'Flutter project detected',
    );
    if (!context.isFlutterProject) failures++;

    terminal.checklist(
      ok: context.hasFlowWidgetDependency,
      message: 'pubspec.yaml depends on flow_widget',
    );
    if (!context.hasFlowWidgetDependency) failures++;

    final hasConfig = await context.configFile.exists();
    terminal.checklist(ok: hasConfig, message: 'flow_widget.yaml present');
    if (!hasConfig) failures++;

    final manifest = File(
      p.join(
        context.root.path,
        'android',
        'app',
        'src',
        'main',
        'AndroidManifest.xml',
      ),
    );
    if (await manifest.exists()) {
      final content = await manifest.readAsString();
      final hasReceiver =
          content.contains('APPWIDGET_UPDATE') ||
          content.contains('flowwidget');
      terminal.checklist(
        ok: hasReceiver,
        message: 'Android manifest mentions App Widget receiver',
      );
      if (!hasReceiver) failures++;
    } else {
      terminal.checklist(
        ok: true,
        message: 'Android manifest (skipped — no android/ folder)',
      );
    }

    final entitlements = File(
      p.join(context.root.path, 'ios', 'Runner', 'Runner.entitlements'),
    );
    if (await entitlements.exists()) {
      final content = await entitlements.readAsString();
      final hasGroup = content.contains(
        'com.apple.security.application-groups',
      );
      terminal.checklist(
        ok: hasGroup,
        message: 'iOS Runner.entitlements includes App Groups',
      );
      if (!hasGroup) failures++;
    } else {
      terminal.checklist(
        ok: true,
        message: 'iOS entitlements (skipped — file not found)',
      );
    }

    if (failures == 0) {
      terminal.success('All checks passed.');
      return 0;
    }

    terminal.warn('$failures check(s) failed.');
    return 1;
  }
}
