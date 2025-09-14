class Settings {
  final bool oldStyle;
  final bool prompt;
  final int debug;
  // Autres paramètres si nécessaire

  Settings({
    required this.oldStyle,
    required this.prompt,
    required this.debug,
  });

  /// Feature flag: enable isolate-based JSON parsing for large assets.
  /// Not enabled by default in S1; may be toggled in S2+ if needed.
  static const bool parseUseIsolate = false;

  /// Threshold in bytes above which isolate parsing may be considered.
  static const int parseIsolateThresholdBytes = 1024 * 1024; // 1 MiB
}
