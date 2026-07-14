/// Uniquely identifies a widget instance on the host platform.
///
/// [name] is the widget family / provider name registered with the OS.
/// [id] is the per-instance identifier (Android `appWidgetId`, iOS
/// `timeline entry` entity, etc.). When `null`, operations apply to all
/// instances of [name].
final class FlowWidgetId {
  /// Creates a widget identifier.
  const FlowWidgetId({required this.name, this.id});

  /// Widget family / provider name (e.g. `"ProfileWidget"`).
  final String name;

  /// Optional per-instance identifier.
  final int? id;

  /// Whether this id targets every instance of [name].
  bool get targetsAllInstances => id == null;

  /// Serializes for MethodChannel transport.
  Map<String, Object?> toWire() => <String, Object?>{
    'name': name,
    if (id != null) 'id': id,
  };

  /// Deserializes from MethodChannel transport.
  factory FlowWidgetId.fromWire(Map<Object?, Object?> wire) {
    return FlowWidgetId(name: wire['name']! as String, id: wire['id'] as int?);
  }

  @override
  bool operator ==(Object other) =>
      other is FlowWidgetId && other.name == name && other.id == id;

  @override
  int get hashCode => Object.hash(name, id);

  @override
  String toString() =>
      id == null ? 'FlowWidgetId($name)' : 'FlowWidgetId($name#$id)';
}
