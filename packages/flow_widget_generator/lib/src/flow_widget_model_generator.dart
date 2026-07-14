import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flow_widget_annotation/flow_widget_annotation.dart';
import 'package:flow_widget_generator/src/field_mapper.dart';
import 'package:source_gen/source_gen.dart';

/// Generates FlowWidget serialization extensions for annotated models.
class FlowWidgetModelGenerator extends GeneratorForAnnotation<FlowWidgetModel> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@FlowWidgetModel can only be applied to classes.',
        element: element,
      );
    }

    final classElement = element;
    final className = classElement.name;
    if (className == null || className.isEmpty) {
      throw InvalidGenerationSourceError(
        '@FlowWidgetModel requires a named class.',
        element: element,
      );
    }

    final prefix = annotation.read('prefix').stringValue;
    final storageKeyReader = annotation.read('storageKey');
    final storageKey =
        storageKeyReader.isNull ? null : storageKeyReader.stringValue;
    final generateJson = annotation.read('generateJson').boolValue;

    final fields = _collectFields(classElement, prefix);
    if (fields.isEmpty) {
      throw InvalidGenerationSourceError(
        '@FlowWidgetModel class must have at least one serializable field.',
        element: element,
      );
    }

    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln("import 'dart:convert';")
      ..writeln(
        "import 'package:flow_widget_platform_interface/flow_widget_platform_interface.dart';",
      )
      ..writeln();

    if (storageKey != null && storageKey.isNotEmpty) {
      buffer.write(
        _generateStorageKeyMode(
          className: className,
          classElement: classElement,
          storageKey: storageKey,
          fields: fields,
          generateJson: generateJson,
        ),
      );
    } else {
      buffer.write(
        _generatePerFieldMode(
          className: className,
          classElement: classElement,
          fields: fields,
          generateJson: generateJson,
        ),
      );
    }

    return buffer.toString();
  }

  List<ModelField> _collectFields(ClassElement classElement, String prefix) {
    final ctor = classElement.unnamedConstructor;
    final defaultParams = <String>{
      if (ctor != null)
        for (final FormalParameterElement p in ctor.formalParameters)
          if (p.hasDefaultValue && p.name != null) p.name!,
    };

    final fields = <ModelField>[];
    for (final field in classElement.fields) {
      if (field.isStatic || field.isSynthetic) continue;
      if (isIgnoredField(field)) continue;
      final name = field.name;
      if (name == null) continue;
      fields.add(
        ModelField(
          name: name,
          type: field.type,
          storageKey: storageKeyForField(field, prefix),
          isNullable:
              field.type.nullabilitySuffix != NullabilitySuffix.none,
          hasDefaultValue: defaultParams.contains(name),
        ),
      );
    }
    return fields;
  }

  String _generatePerFieldMode({
    required String className,
    required ClassElement classElement,
    required List<ModelField> fields,
    required bool generateJson,
  }) {
    final buffer = StringBuffer()
      ..writeln('extension \$${className}FlowWidget on $className {')
      ..writeln('  List<FlowWidgetDataEntry> toFlowEntries() => [')
      ..writeln(
        fields
            .map(
              (f) =>
                  "    FlowWidgetDataEntry(key: '${f.storageKey}', value: ${serializeExpression(f.name, f.type)}),",
            )
            .join('\n'),
      )
      ..writeln('  ];')
      ..writeln();

    if (_canGenerateFromEntries(classElement, fields)) {
      buffer
        ..writeln('  static $className? fromFlowEntries(')
        ..writeln('    Map<String, FlowWidgetValue> data,')
        ..writeln('  ) {');
      for (final field in fields) {
        final expr = deserializeExpression(
          'data',
          field.storageKey,
          field.type,
        );
        buffer.writeln('    final ${field.name} = $expr;');
      }
      buffer.writeln('    return $className(');
      for (final field in fields) {
        final required = !field.isNullable && !field.hasDefaultValue;
        buffer.writeln(
          '      ${field.name}: ${field.name}${required ? '!' : ''},',
        );
      }
      buffer
        ..writeln('    );')
        ..writeln('  }')
        ..writeln();
    }

    if (generateJson) {
      buffer
        ..writeln('  Map<String, Object?> toFlowJson() => {')
        ..writeln(
          fields
              .map(
                (f) =>
                    "    '${f.name}': ${_jsonValueExpression(f.name, f.type)},",
              )
              .join('\n'),
        )
        ..writeln('  };')
        ..writeln();
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _generateStorageKeyMode({
    required String className,
    required ClassElement classElement,
    required String storageKey,
    required List<ModelField> fields,
    required bool generateJson,
  }) {
    final buffer = StringBuffer()
      ..writeln('extension \$${className}FlowWidget on $className {')
      ..writeln('  List<FlowWidgetDataEntry> toFlowEntries() => [')
      ..writeln('    FlowWidgetDataEntry(')
      ..writeln("      key: '$storageKey',")
      ..writeln(
        '      value: FlowWidgetValue.json(jsonEncode(${jsonMapLiteral(fields)})),',
      )
      ..writeln('    ),')
      ..writeln('  ];')
      ..writeln();

    if (_canGenerateFromEntries(classElement, fields)) {
      buffer
        ..writeln('  static $className? fromFlowEntries(')
        ..writeln('    Map<String, FlowWidgetValue> data,')
        ..writeln('  ) {')
        ..writeln("    final raw = data['$storageKey']?.unbox();")
        ..writeln('    if (raw is! String) return null;')
        ..writeln('    final json = jsonDecode(raw) as Map<String, dynamic>;')
        ..writeln('    return $className(');
      for (final field in fields) {
        final expr = jsonDeserializeExpression('json', field.name, field.type);
        buffer.writeln('      ${field.name}: $expr,');
      }
      buffer
        ..writeln('    );')
        ..writeln('  }')
        ..writeln();
    }

    if (generateJson) {
      buffer
        ..writeln('  String toFlowJsonString() => jsonEncode({')
        ..writeln(
          fields
              .map(
                (f) =>
                    "    '${f.name}': ${_jsonValueExpression(f.name, f.type)},",
              )
              .join('\n'),
        )
        ..writeln('  });')
        ..writeln();
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  bool _canGenerateFromEntries(
    ClassElement classElement,
    List<ModelField> fields,
  ) {
    final constructor = classElement.unnamedConstructor;
    if (constructor == null) return false;
    final paramNames = <String>{
      for (final FormalParameterElement p in constructor.formalParameters)
        if (p.name != null) p.name!,
    };
    for (final field in fields) {
      if (!paramNames.contains(field.name)) return false;
    }
    return true;
  }

  String _jsonValueExpression(String fieldName, DartType type) {
    final typeName = type.getDisplayString();
    return switch (typeName) {
      'DateTime' => '$fieldName.toIso8601String()',
      _ when _isEnumType(type) => '$fieldName.name',
      _ => fieldName,
    };
  }

  bool _isEnumType(DartType type) {
    final element = type.element;
    return element is EnumElement;
  }
}
