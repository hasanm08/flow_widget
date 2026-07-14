/// Base exception for all flow_widget failures.
base class FlowWidgetException implements Exception {
  /// Creates a flow_widget exception.
  const FlowWidgetException(this.message, {this.code, this.cause});

  /// Human-readable message.
  final String message;

  /// Stable machine-readable code (e.g. `"not_initialized"`).
  final String? code;

  /// Optional underlying cause.
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('FlowWidgetException');
    if (code != null) buffer.write('($code)');
    buffer.write(': $message');
    if (cause != null) buffer.write('\nCaused by: $cause');
    return buffer.toString();
  }
}

/// Thrown when an API is called before [FlowWidget.initialize].
final class FlowWidgetNotInitializedException extends FlowWidgetException {
  /// Creates a not-initialized exception.
  const FlowWidgetNotInitializedException([
    super.message =
        'FlowWidget.initialize() must be called before using this API.',
  ]) : super(code: 'not_initialized');
}

/// Thrown when the host platform does not support the requested feature.
final class FlowWidgetUnsupportedException extends FlowWidgetException {
  /// Creates an unsupported-feature exception.
  const FlowWidgetUnsupportedException(String feature, {String? platform})
    : super(
        platform == null
            ? 'Feature "$feature" is not supported on this platform.'
            : 'Feature "$feature" is not supported on $platform.',
        code: 'unsupported',
      );
}

/// Thrown when shared storage I/O fails.
final class FlowWidgetStorageException extends FlowWidgetException {
  /// Creates a storage exception.
  const FlowWidgetStorageException(super.message, {super.cause})
    : super(code: 'storage');
}

/// Thrown when a widget update fails on the native side.
final class FlowWidgetUpdateException extends FlowWidgetException {
  /// Creates an update exception.
  const FlowWidgetUpdateException(super.message, {super.cause})
    : super(code: 'update');
}

/// Thrown when Live Activity APIs fail.
final class FlowWidgetLiveActivityException extends FlowWidgetException {
  /// Creates a Live Activity exception.
  const FlowWidgetLiveActivityException(super.message, {super.cause})
    : super(code: 'live_activity');
}
