class AudioSettings {
  AudioSettings({
    required double bgmVolume,
    required double sfxVolume,
  })  : bgmVolume = _clampVolume(bgmVolume),
        sfxVolume = _clampVolume(sfxVolume);

  static const double defaultBgmVolume = 0.6;
  static const double defaultSfxVolume = 1.0;

  final double bgmVolume;
  final double sfxVolume;

  factory AudioSettings.defaults() => AudioSettings(
        bgmVolume: defaultBgmVolume,
        sfxVolume: defaultSfxVolume,
      );

  AudioSettings copyWith({double? bgmVolume, double? sfxVolume}) => AudioSettings(
        bgmVolume: bgmVolume ?? this.bgmVolume,
        sfxVolume: sfxVolume ?? this.sfxVolume,
      );

  static double _clampVolume(double value) => value.clamp(0.0, 1.0).toDouble();
}
