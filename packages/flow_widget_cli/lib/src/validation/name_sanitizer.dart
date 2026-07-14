/// Widget and project naming helpers.
library;

/// Converts a PascalCase widget name into snake_case for file paths.
String widgetNameToSnakeCase(String name) {
  final sanitized = sanitizeWidgetName(name);
  final buffer = StringBuffer();
  for (var i = 0; i < sanitized.length; i++) {
    final char = sanitized[i];
    if (char == char.toUpperCase() && i > 0) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

/// Ensures a widget name is valid PascalCase.
String sanitizeWidgetName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    throw FormatException('Widget name cannot be empty.');
  }
  if (!RegExp(r'^[A-Za-z][A-Za-z0-9]*$').hasMatch(trimmed)) {
    throw FormatException(
      'Widget name must be alphanumeric PascalCase (e.g. WeatherWidget).',
    );
  }
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

/// Validates a storage key prefix.
bool isValidKeyPrefix(String prefix) {
  if (prefix.isEmpty) return true;
  return RegExp(r'^[a-z][a-z0-9_]*_$').hasMatch(prefix);
}

/// Parses a comma-separated platform list.
List<String> parsePlatforms(String raw) {
  return raw
      .split(',')
      .map((p) => p.trim().toLowerCase())
      .where((p) => p.isNotEmpty)
      .toList();
}

const supportedPlatforms = {'android', 'ios', 'macos', 'windows', 'linux'};
