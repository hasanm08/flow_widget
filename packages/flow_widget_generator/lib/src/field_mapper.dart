/// Maps Dart field types to FlowWidgetValue serialization expressions.
library;

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

/// Describes a model field eligible for code generation.
class ModelField {
  ModelField({
    required this.name,
    required this.type,
    required this.storageKey,
    required this.isNullable,
    required this.hasDefaultValue,
  });

  final String name;
  final DartType type;
  final String storageKey;
  final bool isNullable;
  final bool hasDefaultValue;
}

/// Returns the storage key for a field, honoring @FlowWidgetKey.
String storageKeyForField(FieldElement field, String prefix) {
  for (final meta in field.metadata.annotations) {
    final value = meta.computeConstantValue();
    if (value == null) continue;
    if (_constantTypeName(value) == 'FlowWidgetKey') {
      final key = value.getField('name')?.toStringValue();
      if (key != null && key.isNotEmpty) return key;
    }
  }
  return '$prefix${field.name ?? 'field'}';
}

/// Whether the field is excluded via @FlowWidgetIgnore.
bool isIgnoredField(FieldElement field) {
  for (final meta in field.metadata.annotations) {
    final value = meta.computeConstantValue();
    if (value == null) continue;
    if (_constantTypeName(value) == 'FlowWidgetIgnore') return true;
  }
  return false;
}

String? _constantTypeName(DartObject value) {
  return value.type?.element?.name;
}

bool _isEnumType(DartType type) {
  final element = type.element;
  return element is EnumElement;
}

/// Serializes [fieldName] to a FlowWidgetValue expression.
String serializeExpression(String fieldName, DartType type) {
  final typeName = _typeLabel(type);
  return switch (typeName) {
    'String' => 'FlowWidgetValue.string($fieldName)',
    'int' => 'FlowWidgetValue.intValue($fieldName)',
    'double' => 'FlowWidgetValue.doubleValue($fieldName)',
    'bool' => 'FlowWidgetValue.boolValue($fieldName)',
    'DateTime' => 'FlowWidgetValue.dateTime($fieldName)',
    _ when type.isDartCoreList => _serializeList(fieldName, type),
    _ when type.isDartCoreMap => _serializeMap(fieldName),
    _ when _isEnumType(type) => 'FlowWidgetValue.string($fieldName.name)',
    _ => throw UnsupportedError(
      'Unsupported field type $typeName for flow_widget generation.',
    ),
  };
}

/// Deserializes a map entry into a Dart expression for [type].
String deserializeExpression(String mapVar, String key, DartType type) {
  final typeName = _typeLabel(type);
  final lookup = "$mapVar['$key']";
  return switch (typeName) {
    'String' => '$lookup?.unbox() as String?',
    'int' => '$lookup?.unbox() as int?',
    'double' => '($lookup?.unbox() as num?)?.toDouble()',
    'bool' => '$lookup?.unbox() as bool?',
    'DateTime' => '$lookup?.unbox() as DateTime?',
    _ when type.isDartCoreList => '$lookup?.unbox() as List<dynamic>?',
    _ when type.isDartCoreMap => '$lookup?.unbox() as Map<String, dynamic>?',
    _ when _isEnumType(type) =>
      '$lookup == null ? null : ${_typeLabel(type)}.values.byName($lookup.unbox() as String)',
    _ => throw UnsupportedError(
      'Unsupported field type $typeName for flow_widget generation.',
    ),
  };
}

String _typeLabel(DartType type) {
  return type.getDisplayString();
}

String _serializeList(String fieldName, DartType type) {
  if (type is! InterfaceType || type.typeArguments.isEmpty) {
    return 'FlowWidgetValue.list([for (final item in $fieldName) FlowWidgetValue.box(item)])';
  }
  final arg = type.typeArguments.first;
  return 'FlowWidgetValue.list([for (final item in $fieldName) ${serializeExpression('item', arg)}])';
}

String _serializeMap(String fieldName) {
  return 'FlowWidgetValue.map({for (final e in $fieldName.entries) e.key: FlowWidgetValue.box(e.value)})';
}

/// Builds a JSON map literal for storageKey mode.
String jsonMapLiteral(List<ModelField> fields, {String receiver = ''}) {
  final prefix = receiver.isEmpty ? '' : '$receiver.';
  final entries = fields.map((field) {
    final expr = _jsonValueExpression('$prefix${field.name}', field.type);
    return "'${field.name}': $expr";
  });
  return '{${entries.join(', ')}}';
}

String _jsonValueExpression(String fieldName, DartType type) {
  final typeName = _typeLabel(type);
  return switch (typeName) {
    'String' => fieldName,
    'int' || 'double' || 'bool' => fieldName,
    'DateTime' => '$fieldName.toIso8601String()',
    _ when _isEnumType(type) => '$fieldName.name',
    _ when type.isDartCoreList || type.isDartCoreMap => fieldName,
    _ => fieldName,
  };
}

/// Parses JSON map entries back into constructor arguments.
String jsonDeserializeExpression(
  String jsonVar,
  String fieldName,
  DartType type,
) {
  final access = "$jsonVar['$fieldName']";
  final typeName = _typeLabel(type);
  return switch (typeName) {
    'String' => '$access as String?',
    'int' => '($access as num?)?.toInt()',
    'double' => '($access as num?)?.toDouble()',
    'bool' => '$access as bool?',
    'DateTime' => '$access == null ? null : DateTime.parse($access as String)',
    _ when _isEnumType(type) =>
      '$access == null ? null : ${_typeLabel(type)}.values.byName($access as String)',
    _ when type.isDartCoreList => '($access as List?)?.cast<dynamic>()',
    _ when type.isDartCoreMap => '($access as Map?)?.cast<String, dynamic>()',
    _ => access,
  };
}
