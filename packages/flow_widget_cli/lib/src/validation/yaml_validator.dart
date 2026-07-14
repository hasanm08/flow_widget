/// flow_widget.yaml validation helpers.
library;

import 'package:flow_widget_cli/src/validation/name_sanitizer.dart';

class FlowWidgetYamlValidation {
  FlowWidgetYamlValidation({required this.errors, required this.warnings});

  final List<String> errors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty;
}

FlowWidgetYamlValidation validateFlowWidgetYaml(Map<Object?, Object?> yaml) {
  final errors = <String>[];
  final warnings = <String>[];

  if (yaml.isEmpty) {
    errors.add('flow_widget.yaml is empty.');
    return FlowWidgetYamlValidation(errors: errors, warnings: warnings);
  }

  final appGroupId = yaml['appGroupId'];
  if (appGroupId != null && appGroupId is! String) {
    errors.add('appGroupId must be a string.');
  } else if (appGroupId is String && appGroupId.isEmpty) {
    errors.add('appGroupId cannot be empty when set.');
  }

  final platforms = yaml['platforms'];
  if (platforms != null) {
    if (platforms is! List) {
      errors.add('platforms must be a list of strings.');
    } else {
      for (final platform in platforms) {
        if (platform is! String) {
          errors.add('Each platform must be a string.');
          break;
        }
        if (!supportedPlatforms.contains(platform.toLowerCase())) {
          warnings.add('Unknown platform "$platform".');
        }
      }
    }
  }

  final widgets = yaml['widgets'];
  if (widgets == null) {
    warnings.add('No widgets registered yet.');
  } else if (widgets is! List) {
    errors.add('widgets must be a list.');
  } else {
    final names = <String>{};
    for (final widget in widgets) {
      if (widget is! Map) {
        errors.add('Each widget entry must be a map.');
        continue;
      }
      final name = widget['name'];
      if (name == null) {
        errors.add('Each widget requires a name.');
        continue;
      }
      if (name is! String) {
        errors.add('Widget name must be a string.');
        continue;
      }
      try {
        final sanitized = sanitizeWidgetName(name);
        if (names.contains(sanitized)) {
          errors.add('Duplicate widget name "$sanitized".');
        }
        names.add(sanitized);
      } on FormatException catch (e) {
        errors.add('Invalid widget name "$name": ${e.message}');
      }

      final prefix = widget['prefix'];
      if (prefix != null && prefix is String && !isValidKeyPrefix(prefix)) {
        errors.add(
          'Widget "$name" has invalid prefix "$prefix". '
          'Use lowercase snake_case ending with underscore.',
        );
      }
    }
  }

  return FlowWidgetYamlValidation(errors: errors, warnings: warnings);
}
