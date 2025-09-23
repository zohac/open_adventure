import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/audio_settings_repository_impl.dart';
import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioSettingsRepositoryImpl', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('load returns defaults when store is empty', () async {
      final repository = AudioSettingsRepositoryImpl();

      final settings = await repository.load();

      expect(settings.bgmVolume, AudioSettings.defaultBgmVolume);
      expect(settings.sfxVolume, AudioSettings.defaultSfxVolume);
    });

    test('save persists values retrievable via load', () async {
      final repository = AudioSettingsRepositoryImpl();
      final updated = AudioSettings(bgmVolume: 0.35, sfxVolume: 0.8);

      await repository.save(updated);
      final reloaded = await repository.load();

      expect(reloaded.bgmVolume, closeTo(0.35, 0.001));
      expect(reloaded.sfxVolume, closeTo(0.8, 0.001));
    });

    test('load clamps persisted values within range', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'settings.audio.bgmVolume': 1.5,
        'settings.audio.sfxVolume': -0.4,
      });
      final repository = AudioSettingsRepositoryImpl();

      final settings = await repository.load();

      expect(settings.bgmVolume, 1.0);
      expect(settings.sfxVolume, 0.0);
    });
  });
}
