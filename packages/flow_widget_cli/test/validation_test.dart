import 'package:flow_widget_cli/src/validation/name_sanitizer.dart';
import 'package:flow_widget_cli/src/validation/yaml_validator.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('sanitizeWidgetName', () {
    test('accepts PascalCase names', () {
      expect(sanitizeWidgetName('WeatherWidget'), 'WeatherWidget');
      expect(sanitizeWidgetName('weatherWidget'), 'WeatherWidget');
    });

    test('rejects invalid names', () {
      expect(() => sanitizeWidgetName(''), throwsFormatException);
      expect(() => sanitizeWidgetName('123Bad'), throwsFormatException);
      expect(() => sanitizeWidgetName('bad-name'), throwsFormatException);
    });
  });

  group('widgetNameToSnakeCase', () {
    test('converts PascalCase to snake_case', () {
      expect(widgetNameToSnakeCase('WeatherWidget'), 'weather_widget');
      expect(widgetNameToSnakeCase('Dashboard'), 'dashboard');
    });
  });

  group('isValidKeyPrefix', () {
    test('validates storage prefixes', () {
      expect(isValidKeyPrefix(''), isTrue);
      expect(isValidKeyPrefix('dashboard_'), isTrue);
      expect(isValidKeyPrefix('Dashboard_'), isFalse);
      expect(isValidKeyPrefix('dashboard'), isFalse);
    });
  });

  group('validateFlowWidgetYaml', () {
    test('passes for valid config', () {
      final doc =
          loadYaml('''
appGroupId: group.com.example.app
platforms:
  - android
  - ios
widgets:
  - name: WeatherWidget
    prefix: weather_
    platforms:
      - android
''')
              as YamlMap;

      final result = validateFlowWidgetYaml(doc);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('reports duplicate widget names', () {
      final doc =
          loadYaml('''
widgets:
  - name: WeatherWidget
  - name: WeatherWidget
''')
              as YamlMap;

      final result = validateFlowWidgetYaml(doc);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('Duplicate')), isTrue);
    });

    test('reports invalid prefix', () {
      final doc =
          loadYaml('''
widgets:
  - name: WeatherWidget
    prefix: BadPrefix
''')
              as YamlMap;

      final result = validateFlowWidgetYaml(doc);
      expect(result.isValid, isFalse);
    });
  });
}
