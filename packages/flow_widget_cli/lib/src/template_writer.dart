/// Writes generated native boilerplate files.
library;

import 'dart:io';

import 'package:flow_widget_cli/src/project_context.dart';
import 'package:flow_widget_cli/src/templates/android_glance.dart';
import 'package:flow_widget_cli/src/templates/desktop_stub.dart';
import 'package:flow_widget_cli/src/templates/ios_widgetkit.dart';
import 'package:flow_widget_cli/src/templates/macos_widgetkit.dart';
import 'package:flow_widget_cli/src/terminal.dart';
import 'package:flow_widget_cli/src/validation/name_sanitizer.dart';
import 'package:path/path.dart' as p;

class TemplateWriter {
  TemplateWriter({required this.context, required this.terminal});

  final ProjectContext context;
  final Terminal terminal;

  Future<void> writeWidget({
    required String widgetName,
    required List<String> platforms,
    String? outputDir,
  }) async {
    final name = sanitizeWidgetName(widgetName);
    final snake = widgetNameToSnakeCase(name);
    final baseDir = outputDir != null
        ? Directory(p.join(context.root.path, outputDir, name))
        : Directory(p.join(context.flowWidgetDir.path, name));
    final generated = Directory(p.join(baseDir.path, '.generated'));
    await generated.create(recursive: true);

    final appId = context.applicationId ?? '{{applicationId}}';
    final bundleId = context.bundleIdentifier ?? '{{bundleIdentifier}}';
    final appGroupId =
        (await context.readConfig())['appGroupId'] as String? ?? 'group.$appId';

    for (final platform in platforms) {
      switch (platform) {
        case 'android':
          await _writeAndroid(
            generated: generated,
            name: name,
            snake: snake,
            applicationId: appId,
          );
        case 'ios':
          await _writeIos(
            generated: generated,
            name: name,
            snake: snake,
            appGroupId: appGroupId,
            bundleId: bundleId,
          );
        case 'macos':
          await _writeMacos(
            generated: generated,
            name: name,
            appGroupId: appGroupId,
          );
        case 'windows':
        case 'linux':
          await _writeDesktop(
            generated: generated,
            name: name,
            platform: platform,
          );
        default:
          terminal.warn('Skipping unsupported platform "$platform".');
      }
    }

    terminal.success('Generated templates for $name in ${baseDir.path}');
  }

  Future<void> _writeAndroid({
    required Directory generated,
    required String name,
    required String snake,
    required String applicationId,
  }) async {
    final androidDir = Directory(p.join(generated.path, 'android'));
    final kotlinDir = Directory(
      p.join(androidDir.path, 'kotlin', 'dev', 'flowwidget', 'widgets'),
    );
    final resDir = Directory(p.join(androidDir.path, 'res'));
    await kotlinDir.create(recursive: true);
    await Directory(p.join(resDir.path, 'xml')).create(recursive: true);
    await Directory(p.join(resDir.path, 'layout')).create(recursive: true);

    final packageName = 'dev.flowwidget.widgets';
    final providerClass = '$packageName.${name}Receiver';

    await File(p.join(kotlinDir.path, '${name}Widget.kt')).writeAsString(
      androidGlanceProvider(
        applicationId: applicationId,
        widgetName: name,
        packageName: packageName,
      ),
    );
    await File(
      p.join(androidDir.path, 'MainActivity.kt.snippet'),
    ).writeAsString(androidMainActivitySnippet(applicationId: applicationId));
    await File(
      p.join(resDir.path, 'xml', '${snake}_widget_info.xml'),
    ).writeAsString(
      androidWidgetInfoXml(widgetName: name, providerClass: providerClass),
    );
    await File(
      p.join(resDir.path, 'layout', '${snake}_widget_placeholder.xml'),
    ).writeAsString(androidWidgetPlaceholderLayout(widgetName: name));
    await File(
      p.join(androidDir.path, 'AndroidManifest.snippet.xml'),
    ).writeAsString(
      androidManifestSnippet(widgetName: name, providerClass: providerClass),
    );
    await File(
      p.join(androidDir.path, 'strings.snippet.xml'),
    ).writeAsString(androidStringsSnippet(widgetName: name));
    await File(
      p.join(androidDir.path, 'build.gradle.snippet'),
    ).writeAsString(androidGradleDependencies());
  }

  Future<void> _writeIos({
    required Directory generated,
    required String name,
    required String snake,
    required String appGroupId,
    required String bundleId,
  }) async {
    final iosDir = Directory(p.join(generated.path, 'ios', snake));
    await iosDir.create(recursive: true);

    await File(p.join(iosDir.path, '${name}Bundle.swift')).writeAsString(
      iosWidgetBundle(widgetName: name, bundleIdentifier: bundleId),
    );
    await File(
      p.join(iosDir.path, '${name}.swift'),
    ).writeAsString(iosWidget(widgetName: name, appGroupId: appGroupId));
    await File(p.join(iosDir.path, '${name}Provider.swift')).writeAsString(
      iosWidgetProvider(widgetName: name, appGroupId: appGroupId),
    );
    await File(
      p.join(iosDir.path, '${name}Entry.swift'),
    ).writeAsString(iosWidgetEntry(widgetName: name));
    await File(
      p.join(iosDir.path, '${name}EntryView.swift'),
    ).writeAsString(iosWidgetEntryView(widgetName: name));
    await File(p.join(iosDir.path, 'APP_GROUP_SETUP.md')).writeAsString(
      iosAppGroupInstructions(
        appGroupId: appGroupId,
        bundleIdentifier: bundleId,
        widgetName: name,
      ),
    );
    await File(
      p.join(iosDir.path, 'Runner.entitlements.snippet.xml'),
    ).writeAsString(iosEntitlementsSnippet(appGroupId: appGroupId));
  }

  Future<void> _writeMacos({
    required Directory generated,
    required String name,
    required String appGroupId,
  }) async {
    final dir = Directory(p.join(generated.path, 'macos'));
    await dir.create(recursive: true);
    await File(p.join(dir.path, '${name}Widget.swift')).writeAsString(
      macosWidgetKitFiles(widgetName: name, appGroupId: appGroupId),
    );
    await File(
      p.join(dir.path, 'APP_GROUP_SETUP.md'),
    ).writeAsString(macosAppGroupInstructions(appGroupId: appGroupId));
  }

  Future<void> _writeDesktop({
    required Directory generated,
    required String name,
    required String platform,
  }) async {
    final dir = Directory(p.join(generated.path, platform));
    await dir.create(recursive: true);
    await File(
      p.join(dir.path, 'README.md'),
    ).writeAsString(desktopReadme(platform: platform, widgetName: name));
    await File(
      p.join(dir.path, '${name}StorageKeys.dart'),
    ).writeAsString(desktopStorageConstants(widgetName: name));
  }
}
