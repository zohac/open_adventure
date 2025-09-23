import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/controllers/audio_settings_controller.dart';
import 'package:open_adventure/application/services/audio_controller.dart';
import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';
import 'package:open_adventure/domain/usecases/load_audio_settings.dart';
import 'package:open_adventure/domain/usecases/save_audio_settings.dart';
import 'package:open_adventure/presentation/pages/settings_page.dart';

class _MockAudioOutput extends Mock implements AudioOutput {}

class _InMemoryAudioSettingsRepository implements AudioSettingsRepository {
  AudioSettings _settings = AudioSettings.defaults();

  @override
  Future<AudioSettings> load() async => _settings;

  @override
  Future<void> save(AudioSettings settings) async {
    _settings = settings;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sliders update AudioSettingsController and audio output',
      (tester) async {
    final repository = _InMemoryAudioSettingsRepository();
    final load = LoadAudioSettings(repository);
    final save = SaveAudioSettings(repository);
    final audioOutput = _MockAudioOutput();
    when(() => audioOutput.setVolumes(bgm: any(named: 'bgm'), sfx: any(named: 'sfx')))
        .thenAnswer((_) async {});

    final controller = AudioSettingsController(
      loadAudioSettings: load,
      saveAudioSettings: save,
      audioOutput: audioOutput,
    );
    await controller.init();

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          audioSettingsController: controller,
          initializeOnMount: false,
        ),
      ),
    );

    final musicSliderFinder = find.byKey(const Key('settings.audio.bgmSlider'));
    final sfxSliderFinder = find.byKey(const Key('settings.audio.sfxSlider'));

    expect(musicSliderFinder, findsOneWidget);
    expect(sfxSliderFinder, findsOneWidget);

    final musicSlider = tester.widget<Slider>(musicSliderFinder);
    musicSlider.onChanged?.call(0.7);
    await tester.pump();

    verify(() => audioOutput.setVolumes(bgm: 0.7, sfx: null)).called(1);
    expect(controller.value.bgmVolume, closeTo(0.7, 0.001));

    final sfxSlider = tester.widget<Slider>(sfxSliderFinder);
    sfxSlider.onChanged?.call(0.4);
    await tester.pump();

    verify(() => audioOutput.setVolumes(bgm: null, sfx: 0.4)).called(1);
    expect(controller.value.sfxVolume, closeTo(0.4, 0.001));
  });
}
