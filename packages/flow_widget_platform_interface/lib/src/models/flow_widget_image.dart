import 'dart:typed_data';

/// Image payload for widgets, with optional remote URL caching.
final class FlowWidgetImage {
  /// Creates an image from in-memory bytes.
  const FlowWidgetImage.bytes({
    required this.key,
    required Uint8List bytes,
    this.mimeType = 'image/png',
  }) : this.bytes_ = bytes,
       url = null,
       cachePolicy = FlowWidgetImageCachePolicy.none;

  /// Creates an image that should be downloaded and cached by the native host.
  const FlowWidgetImage.remote({
    required this.key,
    required String this.url,
    this.mimeType = 'image/png',
    this.cachePolicy = FlowWidgetImageCachePolicy.disk,
  }) : bytes_ = null;

  /// Storage / lookup key.
  final String key;

  /// In-memory bytes (mutually exclusive with [url]).
  final Uint8List? bytes_;

  /// Remote URL (mutually exclusive with [bytes_]).
  final String? url;

  /// MIME type hint for native decoders.
  final String mimeType;

  /// Cache policy for remote images.
  final FlowWidgetImageCachePolicy cachePolicy;

  /// Whether this image carries local bytes.
  bool get hasBytes => bytes_ != null;

  /// Whether this image is remote.
  bool get isRemote => url != null;

  /// Wire encoding.
  Map<String, Object?> toWire() => <String, Object?>{
    'key': key,
    'mimeType': mimeType,
    'cachePolicy': cachePolicy.name,
    if (bytes_ != null) 'bytes': bytes_,
    if (url != null) 'url': url,
  };
}

/// Native caching strategy for remote widget images.
enum FlowWidgetImageCachePolicy {
  /// Do not cache.
  none,

  /// Memory-only cache.
  memory,

  /// Persistent on-disk cache.
  disk,
}
