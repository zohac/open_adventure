import 'package:flutter/foundation.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';

class AudioSettingsState {
  const AudioSettingsState({
    required this.bgmVolume,
    required this.sfxVolume,
    required this.isLoading,
  });

  final double bgmVolume;
  final double sfxVolume;
  final bool isLoading;

  factory AudioSettingsState.initial() => const AudioSettingsState(
        bgmVolume: AudioSettings.defaultBgmVolume,
        sfxVolume: AudioSettings.defaultSfxVolume,
        isLoading: true,
      );

  AudioSettingsState copyWith({
    double? bgmVolume,
    double? sfxVolume,
    bool? isLoading,
  }) {
    return AudioSettingsState(
      bgmVolume: bgmVolume ?? this.bgmVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AudioSettingsController extends ValueNotifier<AudioSettingsState> {
  AudioSettingsController({
    required LoadAudioSettings loadAudioSettings,
    required SaveAudioSettings saveAudioSettings,
    required AudioOutput audioOutput,
  })  : _loadAudioSettings = loadAudioSettings,
        _saveAudioSettings = saveAudioSettings,
        _audioOutput = audioOutput,
        super(AudioSettingsState.initial());

  final LoadAudioSettings _loadAudioSettings;
  final SaveAudioSettings _saveAudioSettings;
  final AudioOutput _audioOutput;

  AudioSettings _current = AudioSettings.defaults();

  Future<void> init() async {
    value = value.copyWith(isLoading: true);
    final loaded = await _loadAudioSettings();
    _current = loaded;
    value = AudioSettingsState(
      bgmVolume: loaded.bgmVolume,
      sfxVolume: loaded.sfxVolume,
      isLoading: false,
    );
    await _audioOutput.setVolumes(
      bgm: loaded.bgmVolume,
      sfx: loaded.sfxVolume,
    );
  }

  Future<void> updateBgmVolume(double bgmVolume) =>
      _applyUpdate(bgmVolume: bgmVolume);

  Future<void> updateSfxVolume(double sfxVolume) =>
      _applyUpdate(sfxVolume: sfxVolume);

  Future<void> _applyUpdate({double? bgmVolume, double? sfxVolume}) async {
    final updated = _current.copyWith(
      bgmVolume: bgmVolume,
      sfxVolume: sfxVolume,
    );
    _current = updated;
    value = value.copyWith(
      bgmVolume: updated.bgmVolume,
      sfxVolume: updated.sfxVolume,
    );
    await _audioOutput.setVolumes(
      bgm: bgmVolume != null ? updated.bgmVolume : null,
      sfx: sfxVolume != null ? updated.sfxVolume : null,
    );
    await _saveAudioSettings(updated);
  }
}
