import 'package:open_adventure/domain/entities/audio_settings.dart';

abstract class AudioSettingsRepository {
  Future<AudioSettings> load();
  Future<void> save(AudioSettings settings);
}
