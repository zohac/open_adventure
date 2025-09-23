import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';

class _MockAudioOutput extends Mock implements AudioOutput {}

class _InMemoryAudioSettingsRepository implements AudioSettingsRepository {
  AudioSettings current = AudioSettings.defaults();

  @override
  Future<AudioSettings> load() async => current;

  @override
  Future<void> save(AudioSettings settings) async {
    current = settings;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryAudioSettingsRepository repository;
  late LoadAudioSettings loadAudioSettings;
  late SaveAudioSettings saveAudioSettings;
  late _MockAudioOutput audioOutput;
  late AudioSettingsController controller;

  setUp(() {
    repository = _InMemoryAudioSettingsRepository();
    loadAudioSettings = LoadAudioSettings(repository);
    saveAudioSettings = SaveAudioSettings(repository);
    audioOutput = _MockAudioOutput();

    controller = AudioSettingsController(
      loadAudioSettings: loadAudioSettings,
      saveAudioSettings: saveAudioSettings,
      audioOutput: audioOutput,
    );
  });

  group('init', () {
    test('loads stored values, updates state and applies volumes', () async {
      repository.current = AudioSettings(bgmVolume: 0.2, sfxVolume: 0.8);
      when(() => audioOutput.setVolumes(bgm: any(named: 'bgm'), sfx: any(named: 'sfx')))
          .thenAnswer((_) async {});

      await controller.init();

      final state = controller.value;
      expect(state.isLoading, isFalse);
      expect(state.bgmVolume, repository.current.bgmVolume);
      expect(state.sfxVolume, repository.current.sfxVolume);
      verify(() => audioOutput.setVolumes(
            bgm: repository.current.bgmVolume,
            sfx: repository.current.sfxVolume,
          )).called(1);
    });
  });

  group('update', () {
    setUp(() {
      when(() => audioOutput.setVolumes(bgm: any(named: 'bgm'), sfx: any(named: 'sfx')))
          .thenAnswer((_) async {});
    });

    test('updateBgmVolume refreshes state, audio output, and persistence',
        () async {
      await controller.init();

      await controller.updateBgmVolume(0.45);

      expect(controller.value.bgmVolume, closeTo(0.45, 0.001));
      verify(() => audioOutput.setVolumes(bgm: 0.45, sfx: null)).called(1);
      expect(repository.current.bgmVolume, closeTo(0.45, 0.001));
      expect(repository.current.sfxVolume, AudioSettings.defaultSfxVolume);
    });

    test('updateSfxVolume refreshes state, audio output, and persistence',
        () async {
      await controller.init();

      await controller.updateSfxVolume(0.3);

      expect(controller.value.sfxVolume, closeTo(0.3, 0.001));
      verify(() => audioOutput.setVolumes(bgm: null, sfx: 0.3)).called(1);
      expect(repository.current.sfxVolume, closeTo(0.3, 0.001));
      expect(repository.current.bgmVolume, AudioSettings.defaultBgmVolume);
    });
  });
}
