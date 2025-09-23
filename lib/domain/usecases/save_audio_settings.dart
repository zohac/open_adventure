import 'package:open_adventure/domain/entities/audio_settings.dart';
import 'package:open_adventure/domain/repositories/audio_settings_repository.dart';

class SaveAudioSettings {
  const SaveAudioSettings(this._repository);

  final AudioSettingsRepository _repository;

  Future<void> call(AudioSettings settings) => _repository.save(settings);
}
