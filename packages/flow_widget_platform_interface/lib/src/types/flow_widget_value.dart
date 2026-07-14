import 'dart:typed_data';

/// Strongly typed value suitable for cross-process shared storage.
///
/// Avoids runtime type checks on the Dart side by encoding a discriminant
/// that the native codec can switch on directly.
sealed class FlowWidgetValue {
  /// Creates a [FlowWidgetValue].
  const FlowWidgetValue();

  /// String value.
  const factory FlowWidgetValue.string(String value) = FlowWidgetStringValue;

  /// 64-bit integer value.
  const factory FlowWidgetValue.intValue(int value) = FlowWidgetIntValue;

  /// Double-precision floating point value.
  const factory FlowWidgetValue.doubleValue(double value) =
      FlowWidgetDoubleValue;

  /// Boolean value.
  const factory FlowWidgetValue.boolValue(bool value) = FlowWidgetBoolValue;

  /// Absolute timestamp.
  const factory FlowWidgetValue.dateTime(DateTime value) =
      FlowWidgetDateTimeValue;

  /// UTF-8 JSON string (pre-encoded for zero re-serialization on read).
  const factory FlowWidgetValue.json(String encoded) = FlowWidgetJsonValue;

  /// Raw bytes (images, protobuf payloads, etc.).
  const factory FlowWidgetValue.bytes(Uint8List value) = FlowWidgetBytesValue;

  /// Nested string-keyed map of values.
  const factory FlowWidgetValue.map(Map<String, FlowWidgetValue> value) =
      FlowWidgetMapValue;

  /// Homogeneous list of values.
  const factory FlowWidgetValue.list(List<FlowWidgetValue> value) =
      FlowWidgetListValue;

  /// Wire discriminant for MethodChannel encoding.
  String get typeName;

  /// Converts this value into a MethodChannel-compatible map.
  Map<String, Object?> toWire();

  /// Parses a wire map produced by [toWire] or the native side.
  static FlowWidgetValue fromWire(Map<Object?, Object?> wire) {
    final type = wire['t'] as String?;
    final value = wire['v'];
    return switch (type) {
      's' => FlowWidgetValue.string(value! as String),
      'i' => FlowWidgetValue.intValue(value! as int),
      'd' => FlowWidgetValue.doubleValue((value! as num).toDouble()),
      'b' => FlowWidgetValue.boolValue(value! as bool),
      'dt' => FlowWidgetValue.dateTime(
        DateTime.fromMillisecondsSinceEpoch(value! as int, isUtc: true),
      ),
      'j' => FlowWidgetValue.json(value! as String),
      'bin' => FlowWidgetValue.bytes(
        value is Uint8List
            ? value
            : Uint8List.fromList(List<int>.from(value! as List<dynamic>)),
      ),
      'm' => FlowWidgetValue.map({
        for (final entry in (value! as Map).entries)
          entry.key as String: FlowWidgetValue.fromWire(
            Map<Object?, Object?>.from(entry.value as Map),
          ),
      }),
      'l' => FlowWidgetValue.list([
        for (final item in value! as List)
          FlowWidgetValue.fromWire(Map<Object?, Object?>.from(item as Map)),
      ]),
      _ => throw FormatException('Unknown FlowWidgetValue type: $type'),
    };
  }

  /// Convenience: boxes a Dart primitive into a [FlowWidgetValue].
  ///
  /// Supported inputs: [String], [int], [double], [bool], [DateTime],
  /// [Uint8List], `Map`, `List`, and existing [FlowWidgetValue] instances.
  static FlowWidgetValue box(Object? value) {
    if (value == null) {
      throw ArgumentError('null is not a valid FlowWidgetValue');
    }
    if (value is FlowWidgetValue) return value;
    if (value is String) return FlowWidgetValue.string(value);
    if (value is int) return FlowWidgetValue.intValue(value);
    if (value is double) return FlowWidgetValue.doubleValue(value);
    if (value is bool) return FlowWidgetValue.boolValue(value);
    if (value is DateTime) return FlowWidgetValue.dateTime(value);
    if (value is Uint8List) return FlowWidgetValue.bytes(value);
    if (value is Map) {
      return FlowWidgetValue.map({
        for (final MapEntry<dynamic, dynamic> e in value.entries)
          e.key as String: FlowWidgetValue.box(e.value),
      });
    }
    if (value is List) {
      return FlowWidgetValue.list([
        for (final Object? item in value) FlowWidgetValue.box(item),
      ]);
    }
    throw ArgumentError(
      'Unsupported type ${value.runtimeType} for FlowWidgetValue.box',
    );
  }


  /// Unboxes to a plain Dart value suitable for JSON or logging.
  Object? unbox();
}

/// String [FlowWidgetValue].
final class FlowWidgetStringValue extends FlowWidgetValue {
  /// Creates a string value.
  const FlowWidgetStringValue(this.value);

  /// Underlying string.
  final String value;

  @override
  String get typeName => 's';

  @override
  Map<String, Object?> toWire() => <String, Object?>{'t': typeName, 'v': value};

  @override
  Object? unbox() => value;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetStringValue && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Integer [FlowWidgetValue].
final class FlowWidgetIntValue extends FlowWidgetValue {
  /// Creates an int value.
  const FlowWidgetIntValue(this.value);

  /// Underlying int.
  final int value;

  @override
  String get typeName => 'i';

  @override
  Map<String, Object?> toWire() => <String, Object?>{'t': typeName, 'v': value};

  @override
  Object? unbox() => value;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetIntValue && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Double [FlowWidgetValue].
final class FlowWidgetDoubleValue extends FlowWidgetValue {
  /// Creates a double value.
  const FlowWidgetDoubleValue(this.value);

  /// Underlying double.
  final double value;

  @override
  String get typeName => 'd';

  @override
  Map<String, Object?> toWire() => <String, Object?>{'t': typeName, 'v': value};

  @override
  Object? unbox() => value;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetDoubleValue && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Bool [FlowWidgetValue].
final class FlowWidgetBoolValue extends FlowWidgetValue {
  /// Creates a bool value.
  const FlowWidgetBoolValue(this.value);

  /// Underlying bool.
  final bool value;

  @override
  String get typeName => 'b';

  @override
  Map<String, Object?> toWire() => <String, Object?>{'t': typeName, 'v': value};

  @override
  Object? unbox() => value;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetBoolValue && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// DateTime [FlowWidgetValue] (stored as UTC epoch millis).
final class FlowWidgetDateTimeValue extends FlowWidgetValue {
  /// Creates a DateTime value.
  const FlowWidgetDateTimeValue(this.value);

  /// Underlying DateTime.
  final DateTime value;

  @override
  String get typeName => 'dt';

  @override
  Map<String, Object?> toWire() => <String, Object?>{
    't': typeName,
    'v': value.toUtc().millisecondsSinceEpoch,
  };

  @override
  Object? unbox() => value;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetDateTimeValue && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Pre-encoded JSON string [FlowWidgetValue].
final class FlowWidgetJsonValue extends FlowWidgetValue {
  /// Creates a JSON value.
  const FlowWidgetJsonValue(this.encoded);

  /// UTF-8 JSON string.
  final String encoded;

  @override
  String get typeName => 'j';

  @override
  Map<String, Object?> toWire() => <String, Object?>{
    't': typeName,
    'v': encoded,
  };

  @override
  Object? unbox() => encoded;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetJsonValue && other.encoded == encoded;

  @override
  int get hashCode => encoded.hashCode;
}

/// Bytes [FlowWidgetValue].
final class FlowWidgetBytesValue extends FlowWidgetValue {
  /// Creates a bytes value.
  const FlowWidgetBytesValue(this.value);

  /// Underlying bytes.
  final Uint8List value;

  @override
  String get typeName => 'bin';

  @override
  Map<String, Object?> toWire() => <String, Object?>{'t': typeName, 'v': value};

  @override
  Object? unbox() => value;

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetBytesValue && _listEquals(other.value, value);

  @override
  int get hashCode => Object.hashAll(value);
}

/// Map [FlowWidgetValue].
final class FlowWidgetMapValue extends FlowWidgetValue {
  /// Creates a map value.
  const FlowWidgetMapValue(this.value);

  /// Underlying map.
  final Map<String, FlowWidgetValue> value;

  @override
  String get typeName => 'm';

  @override
  Map<String, Object?> toWire() => <String, Object?>{
    't': typeName,
    'v': <String, Object?>{
      for (final e in value.entries) e.key: e.value.toWire(),
    },
  };

  @override
  Object? unbox() => <String, Object?>{
    for (final e in value.entries) e.key: e.value.unbox(),
  };

  @override
  bool operator ==(Object other) {
    if (other is! FlowWidgetMapValue || other.value.length != value.length) {
      return false;
    }
    for (final e in value.entries) {
      if (other.value[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hashAll(value.entries.map((e) => Object.hash(e.key, e.value)));
}

/// List [FlowWidgetValue].
final class FlowWidgetListValue extends FlowWidgetValue {
  /// Creates a list value.
  const FlowWidgetListValue(this.value);

  /// Underlying list.
  final List<FlowWidgetValue> value;

  @override
  String get typeName => 'l';

  @override
  Map<String, Object?> toWire() => <String, Object?>{
    't': typeName,
    'v': <Object?>[for (final item in value) item.toWire()],
  };

  @override
  Object? unbox() => <Object?>[for (final item in value) item.unbox()];

  @override
  bool operator ==(Object other) {
    if (other is! FlowWidgetListValue || other.value.length != value.length) {
      return false;
    }
    for (var i = 0; i < value.length; i++) {
      if (other.value[i] != value[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(value);
}

bool _listEquals(Uint8List a, Uint8List b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
