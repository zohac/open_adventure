import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/application/services/audio_controller.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _MockAudioSession extends Mock implements AudioSession {}

class _FakeAudioSessionConfiguration extends Fake
    implements AudioSessionConfiguration {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeAudioSessionConfiguration());
    registerFallbackValue(LoopMode.one);
  });

  group('default resolvers', () {
    test('bgm resolver lowercases keys and generates OGG path', () {
      expect(
        defaultBgmAssetResolver('STREAM_GURGLES'),
        equals('assets/audio/music/stream_gurgles.ogg'),
      );
    });

    test('sfx resolver lowercases keys and generates OGG path', () {
      expect(
        defaultSfxAssetResolver('LAMP_ON'),
        equals('assets/audio/sfx/lamp_on.ogg'),
      );
    });
  });

  group('AudioController', () {
    late _MockAudioSession session;
    late _MockAudioPlayer bgmPlayer;
    late _MockAudioPlayer sfxPlayer;
    late StreamController<AudioInterruptionEvent> interruptionEvents;
    late StreamController<void> becomingNoisyEvents;
    late AudioController controller;
    late bool isPlaying;

    setUp(() {
      session = _MockAudioSession();
      bgmPlayer = _MockAudioPlayer();
      sfxPlayer = _MockAudioPlayer();
      interruptionEvents = StreamController<AudioInterruptionEvent>.broadcast();
      becomingNoisyEvents = StreamController<void>.broadcast();
      isPlaying = false;

      when(() => session.configure(any())).thenAnswer((_) async {});
      when(() => session.interruptionEventStream)
          .thenAnswer((_) => interruptionEvents.stream);
      when(() => session.becomingNoisyEventStream)
          .thenAnswer((_) => becomingNoisyEvents.stream);
      when(() => session.setActive(any())).thenAnswer((_) async => true);

      when(() => bgmPlayer.setVolume(any())).thenAnswer((_) async {});
      when(() => sfxPlayer.setVolume(any())).thenAnswer((_) async {});
      when(() => bgmPlayer.playing).thenAnswer((_) => isPlaying);
      when(() => bgmPlayer.setLoopMode(any())).thenAnswer((_) async {});
      when(() => bgmPlayer.setAsset(any()))
          .thenAnswer((_) async => const Duration(milliseconds: 500));
      when(() => bgmPlayer.play()).thenAnswer((_) async {
        isPlaying = true;
      });
      when(() => bgmPlayer.pause()).thenAnswer((_) async {
        isPlaying = false;
      });
      when(() => bgmPlayer.stop()).thenAnswer((_) async {
        isPlaying = false;
      });
      when(() => bgmPlayer.dispose()).thenAnswer((_) async {});

      when(() => sfxPlayer.setAsset(any()))
          .thenAnswer((_) async => const Duration(milliseconds: 200));
      when(() => sfxPlayer.seek(any())).thenAnswer((_) async {});
      when(() => sfxPlayer.play()).thenAnswer((_) async {});
      when(() => sfxPlayer.dispose()).thenAnswer((_) async {});

      controller = AudioController(
        sessionProvider: () async => session,
        bgmPlayer: bgmPlayer,
        sfxPlayer: sfxPlayer,
        registerLifecycleListener: false,
      );
    });

    tearDown(() async {
      await controller.dispose();
      await interruptionEvents.close();
      await becomingNoisyEvents.close();
    });

    test('init configures audio session and volumes once', () async {
      await controller.init();

      verify(() => session.configure(any())).called(1);
      verify(() => bgmPlayer.setVolume(0.6)).called(1);
      verify(() => sfxPlayer.setVolume(1.0)).called(1);

      clearInteractions(session);
      await controller.init();
      verifyNever(() => session.configure(any()));
    });

    test('playBgm sets the asset, loop mode and starts playback', () async {
      await controller.playBgm('STREAM_GURGLES');

      verify(() => session.setActive(true)).called(1);
      verify(() => bgmPlayer.setLoopMode(LoopMode.one)).called(1);
      verify(() => bgmPlayer.setAsset('assets/audio/music/stream_gurgles.ogg'))
          .called(1);
      verify(() => bgmPlayer.play()).called(1);

      clearInteractions(bgmPlayer);
      clearInteractions(session);

      await controller.playBgm('STREAM_GURGLES');

      verifyNever(() => bgmPlayer.setAsset(any()));
      verify(() => bgmPlayer.play()).called(1);
    });

    test('stopBgm stops playback and clears resume intent', () async {
      await controller.playBgm('STREAM_GURGLES');
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);

      await controller.stopBgm();
      verify(() => bgmPlayer.stop()).called(1);

      clearInteractions(bgmPlayer);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => bgmPlayer.play());
    });

    test('playSfx loads asset, seeks to start and plays once', () async {
      await controller.playSfx('LAMP_ON');

      verify(() => session.setActive(true)).called(1);
      verify(() => sfxPlayer.setAsset('assets/audio/sfx/lamp_on.ogg')).called(1);
      verify(() => sfxPlayer.seek(Duration.zero)).called(1);
      verify(() => sfxPlayer.play()).called(1);
    });

    test('lifecycle pause/resume pauses and restarts current BGM', () async {
      await controller.playBgm('STREAM_GURGLES');
      expect(isPlaying, isTrue);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      await Future<void>.delayed(Duration.zero);
      expect(isPlaying, isFalse);

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);
      expect(isPlaying, isTrue);
    });

    test('interruption events pause and resume playback', () async {
      await controller.playBgm('STREAM_GURGLES');
      expect(isPlaying, isTrue);

      controller.handleAudioInterruption(
        AudioInterruptionEvent(true, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);
      expect(isPlaying, isFalse);

      controller.handleAudioInterruption(
        AudioInterruptionEvent(false, AudioInterruptionType.pause),
      );
      await Future<void>.delayed(Duration.zero);
      expect(isPlaying, isTrue);
    });

    test('setVolumes clamps values between 0 and 1', () async {
      await controller.setVolumes(bgm: 1.2, sfx: -0.5);

      verify(() => bgmPlayer.setVolume(1.0)).called(1);
      verify(() => sfxPlayer.setVolume(0.0)).called(1);
    });
  });
}
