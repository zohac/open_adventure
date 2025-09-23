import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';

class LoadAudioSettings {
  const LoadAudioSettings(this._repository);

  final AudioSettingsRepository _repository;

  Future<AudioSettings> call() => _repository.load();
}
