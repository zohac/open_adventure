import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

/// Resolves an asset path for the provided [key]. Keep the mapping confined to
/// this layer so higher layers only reason about semantic keys.
typedef AudioAssetPathResolver = String Function(String key);

/// Lazily provides an [AudioSession] instance (allows overriding in tests).
typedef AudioSessionProvider = Future<AudioSession> Function();

/// Default resolver for background music assets (S2 — simple lowercase mapping).
String defaultBgmAssetResolver(String key) {
  final normalized = key.trim();
  if (normalized.isEmpty) return '';
  return 'assets/audio/music/${normalized.toLowerCase()}.ogg';
}

/// Default resolver for sound effects assets (S2 — snake_case mapping).
String defaultSfxAssetResolver(String key) {
  final normalized = key.trim();
  if (normalized.isEmpty) return '';
  return 'assets/audio/sfx/${normalized.toLowerCase()}.ogg';
}

/// Centralised audio service (S2) responsible for bootstrapping `just_audio`,
/// handling audio focus via `audio_session`, and reacting to lifecycle changes.
///
/// The controller is architected for clean testability: callers inject
/// lightweight mocks for [AudioPlayer]s and the [AudioSessionProvider].
class AudioController with WidgetsBindingObserver {
  AudioController({
    AudioSessionProvider? sessionProvider,
    AudioPlayer? bgmPlayer,
    AudioPlayer? sfxPlayer,
    AudioAssetPathResolver? bgmAssetResolver,
    AudioAssetPathResolver? sfxAssetResolver,
    WidgetsBinding? widgetsBinding,
    double initialBgmVolume = _defaultBgmVolume,
    double initialSfxVolume = _defaultSfxVolume,
    bool registerLifecycleListener = true,
  })  : _sessionProvider = sessionProvider ?? _defaultSessionProvider,
        _bgmPlayer = bgmPlayer ?? AudioPlayer(),
        _sfxPlayer = sfxPlayer ?? AudioPlayer(),
        _bgmAssetResolver = bgmAssetResolver ?? defaultBgmAssetResolver,
        _sfxAssetResolver = sfxAssetResolver ?? defaultSfxAssetResolver,
        _binding = widgetsBinding ?? WidgetsBinding.instance,
        _registerLifecycleListener = registerLifecycleListener,
        _bgmVolume = initialBgmVolume.clamp(0.0, 1.0),
        _sfxVolume = initialSfxVolume.clamp(0.0, 1.0);

  static const double _defaultBgmVolume = 0.6;
  static const double _defaultSfxVolume = 1.0;

  final AudioSessionProvider _sessionProvider;
  final AudioPlayer _bgmPlayer;
  final AudioPlayer _sfxPlayer;
  final AudioAssetPathResolver _bgmAssetResolver;
  final AudioAssetPathResolver _sfxAssetResolver;
  final WidgetsBinding? _binding;
  final bool _registerLifecycleListener;

  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<dynamic>? _becomingNoisySub;
  bool _initialized = false;
  bool _disposed = false;
  bool _resumeAfterFocus = false;
  String? _currentBgmKey;
  double _bgmVolume;
  double _sfxVolume;

  static Future<AudioSession> _defaultSessionProvider() => AudioSession.instance;

  /// Configures the audio session and lifecycle hooks. Safe to call multiple
  /// times; subsequent invocations are no-ops.
  Future<void> init() async {
    if (_initialized || _disposed) return;

    _session = await _sessionProvider();
    await _session?.configure(const AudioSessionConfiguration.music());

    _interruptionSub =
        _session?.interruptionEventStream.listen(_handleInterruption);
    _becomingNoisySub =
        _session?.becomingNoisyEventStream.listen((_) => _pauseBgmForFocusLoss());

    if (_registerLifecycleListener) {
      _binding?.addObserver(this);
    }

    await _bgmPlayer.setVolume(_bgmVolume);
    await _sfxPlayer.setVolume(_sfxVolume);

    _initialized = true;
  }

  /// Plays (or resumes) the background music track associated with [trackKey].
  Future<void> playBgm(String trackKey) async {
    if (_disposed) return;
    await init();

    final assetPath = _bgmAssetResolver(trackKey);
    if (assetPath.isEmpty) {
      debugPrint('AudioController: empty asset path for BGM "$trackKey"');
      return;
    }

    try {
      if (_currentBgmKey != trackKey) {
        await _session?.setActive(true);
        await _bgmPlayer.setLoopMode(LoopMode.one);
        await _bgmPlayer.setAsset(assetPath);
        _currentBgmKey = trackKey;
      } else if (!_bgmPlayer.playing) {
        await _session?.setActive(true);
      }

      await _bgmPlayer.play();
      _resumeAfterFocus = true;
    } on PlayerException catch (error, stackTrace) {
      debugPrint('AudioController: failed to play BGM $trackKey: $error');
      debugPrintStack(stackTrace: stackTrace);
    } on PlayerInterruptedException catch (error, stackTrace) {
      debugPrint('AudioController: playback interrupted for BGM $trackKey');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Stops the currently playing background music.
  Future<void> stopBgm() async {
    if (_disposed) return;
    _resumeAfterFocus = false;
    _currentBgmKey = null;
    try {
      await _bgmPlayer.stop();
    } on PlayerException catch (error, stackTrace) {
      debugPrint('AudioController: failed to stop BGM: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Plays a one-shot sound effect mapped by [effectKey].
  Future<void> playSfx(String effectKey) async {
    if (_disposed) return;
    await init();

    final assetPath = _sfxAssetResolver(effectKey);
    if (assetPath.isEmpty) {
      debugPrint('AudioController: empty asset path for SFX "$effectKey"');
      return;
    }

    try {
      await _session?.setActive(true);
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.seek(Duration.zero);
      await _sfxPlayer.play();
    } on PlayerException catch (error, stackTrace) {
      debugPrint('AudioController: failed to play SFX $effectKey: $error');
      debugPrintStack(stackTrace: stackTrace);
    } on PlayerInterruptedException catch (error, stackTrace) {
      debugPrint('AudioController: playback interrupted for SFX $effectKey');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Adjusts the current volumes (clamped to [0, 1]).
  Future<void> setVolumes({double? bgm, double? sfx}) async {
    if (_disposed) return;
    await init();
    if (bgm != null) {
      _bgmVolume = bgm.clamp(0.0, 1.0);
      await _bgmPlayer.setVolume(_bgmVolume);
    }
    if (sfx != null) {
      _sfxVolume = sfx.clamp(0.0, 1.0);
      await _sfxPlayer.setVolume(_sfxVolume);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        unawaited(_pauseBgmForFocusLoss());
        break;
      case AppLifecycleState.resumed:
        unawaited(_resumeBgmIfNeeded());
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _pauseBgmForFocusLoss() async {
    if (_disposed) return;
    if (_bgmPlayer.playing) {
      _resumeAfterFocus = true;
      await _bgmPlayer.pause();
    } else {
      _resumeAfterFocus = false;
    }
  }

  Future<void> _resumeBgmIfNeeded() async {
    if (_disposed || !_resumeAfterFocus || _currentBgmKey == null) {
      return;
    }
    await _session?.setActive(true);
    await _bgmPlayer.play();
  }

  void _handleInterruption(AudioInterruptionEvent event) {
    if (_disposed) return;
    if (event.begin) {
      unawaited(_pauseBgmForFocusLoss());
    } else {
      unawaited(_resumeBgmIfNeeded());
    }
  }

  /// Visible for testing so unit tests can emulate une interruption.
  @visibleForTesting
  void handleAudioInterruption(AudioInterruptionEvent event) =>
      _handleInterruption(event);

  /// Cleans up the players and subscriptions.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    if (_registerLifecycleListener) {
      _binding?.removeObserver(this);
    }
    await _interruptionSub?.cancel();
    await _becomingNoisySub?.cancel();
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
