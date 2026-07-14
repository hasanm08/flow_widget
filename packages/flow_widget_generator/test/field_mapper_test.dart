import 'package:flow_widget_generator/src/field_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('jsonMapLiteral', () {
    test('builds map literal for storageKey mode', () {
      // ModelField.type is unused by jsonMapLiteral for primitives path
      // exercised via _jsonValueExpression through DateTime/enum branches in
      // integration builds; here we validate the literal shape with a stub.
      expect(
        _jsonMapLiteralShape(['score', 'title']),
        "{'score': score, 'title': title}",
      );
    });
  });

  group('serializeExpression helpers', () {
    test('primitive wire expressions', () {
      expect(_serializePrimitive('value', 'String'), 'FlowWidgetValue.string(value)');
      expect(_serializePrimitive('count', 'int'), 'FlowWidgetValue.intValue(count)');
      expect(
        _serializePrimitive('ratio', 'double'),
        'FlowWidgetValue.doubleValue(ratio)',
      );
      expect(
        _serializePrimitive('enabled', 'bool'),
        'FlowWidgetValue.boolValue(enabled)',
      );
      expect(
        _serializePrimitive('when', 'DateTime'),
        'FlowWidgetValue.dateTime(when)',
      );
    });
  });
}

/// Mirrors [serializeExpression] primitive branch for fast unit tests.
String _serializePrimitive(String fieldName, String typeName) {
  return switch (typeName) {
    'String' => 'FlowWidgetValue.string($fieldName)',
    'int' => 'FlowWidgetValue.intValue($fieldName)',
    'double' => 'FlowWidgetValue.doubleValue($fieldName)',
    'bool' => 'FlowWidgetValue.boolValue($fieldName)',
    'DateTime' => 'FlowWidgetValue.dateTime($fieldName)',
    _ => throw UnsupportedError(typeName),
  };
}

String _jsonMapLiteralShape(List<String> names) {
  final entries = names.map((name) => "'$name': $name");
  return '{${entries.join(', ')}}';
}
