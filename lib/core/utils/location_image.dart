// lib/core/utils/location_image.dart
// Utility helpers for mapping a location to an image asset key/path.

/// Resolves the canonical asset key for a location image using the ordering
/// mandated by the spec (mapTag → snake_case(name) → id → "unknown").
String computeLocationImageKey({String? mapTag, String? name, int? id}) {
  final String? tag = _sanitize(mapTag);
  if (tag != null && tag.isNotEmpty) return tag;
  final String? nm = _toSnakeCase(name);
  if (nm != null && nm.isNotEmpty) return nm;
  if (id != null) return id.toString();
  return 'unknown';
}

/// Builds the asset path for the provided [key] under the mandated directory.
String imageAssetPathFromKey(String key) => 'assets/images/locations/$key.webp';

String? _sanitize(String? s) {
  if (s == null) return null;
  final String t = s.trim();
  return t.isEmpty ? null : _toSnakeCase(t);
}

String? _toSnakeCase(String? s) {
  if (s == null) return null;
  final String trimmed = s.trim();
  if (trimmed.isEmpty) return '';
  final String lower = trimmed
      .replaceAll(RegExp(r"[\s\-]+"), '_')
      .replaceAll(RegExp(r"[^a-zA-Z0-9_]+"), '')
      .toLowerCase();
  // Collapse multiple underscores.
  return lower.replaceAll(RegExp(r'_+'), '_');
}
