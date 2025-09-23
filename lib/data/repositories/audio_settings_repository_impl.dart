import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioSettingsRepositoryImpl implements AudioSettingsRepository {
  AudioSettingsRepositoryImpl({
    Future<SharedPreferences> Function()? preferencesProvider,
  }) : _preferencesProvider = preferencesProvider ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _preferencesProvider;

  static const String _bgmKey = 'settings.audio.bgmVolume';
  static const String _sfxKey = 'settings.audio.sfxVolume';

  @override
  Future<AudioSettings> load() async {
    final prefs = await _preferencesProvider();
    final bgm = prefs.getDouble(_bgmKey) ?? AudioSettings.defaultBgmVolume;
    final sfx = prefs.getDouble(_sfxKey) ?? AudioSettings.defaultSfxVolume;
    return AudioSettings(bgmVolume: bgm, sfxVolume: sfx);
  }

  @override
  Future<void> save(AudioSettings settings) async {
    final prefs = await _preferencesProvider();
    await prefs.setDouble(_bgmKey, settings.bgmVolume);
    await prefs.setDouble(_sfxKey, settings.sfxVolume);
  }
}
