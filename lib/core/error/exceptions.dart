/// Exceptions used by the data layer to report parsing/format issues.
///
/// These are thrown by asset/data parsers and are meant to be handled at
/// repository boundaries or surfaced in tests. They are distinct from
/// domain Failures which represent recoverable business errors.
class AssetDataFormatException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Asset path that caused the error (if known).
  final String? assetPath;

  /// Optional expected JSON root type (e.g., 'List' or 'Map').
  final String? expectedType;

  /// Creates a descriptive format exception for asset parsing.
  const AssetDataFormatException(this.message, {this.assetPath, this.expectedType});

  @override
  String toString() {
    final buf = StringBuffer('AssetDataFormatException: $message');
    if (assetPath != null) buf.write(' (asset: $assetPath)');
    if (expectedType != null) buf.write(' [expected: $expectedType]');
    return buf.toString();
  }
}

/// Thrown when a lookup for an id/name fails in lookup utilities.
class LookupNotFoundException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Creates a not-found exception with [message].
  const LookupNotFoundException(this.message);

  @override
  String toString() => 'LookupNotFoundException: $message';
}
