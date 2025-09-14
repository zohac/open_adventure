// lib/features/adventure/data/models/sound_model.dart

import '../../domain/enums/sound.dart';

class SoundModel {
  static Sound fromString(String? soundStr) {
    switch (soundStr) {
      case 'STREAM_GURGLES':
        return Sound.streamGurgles;
      case 'WIND_WHISTLES' :
        return Sound.windWhistles;
      case 'STREAM_SPLASHES' :
        return Sound.streamSplashes;
      case 'NO_MEANING' :
        return Sound.noMeaning;
      case 'MURMURING_SNORING' :
        return Sound.murmuringSnoring;
      case 'SNAKES_HISSING' :
        return Sound.snakesHissing;
      case 'DULL_RUMBLING' :
        return Sound.dullRumbling;
      case 'LOUD_ROAR' :
        return Sound.loudRoar;
      case 'TOTAL_ROAR' :
        return Sound.totalRoar;
      case 'WATERS_CRASHING' :
        return Sound.watersCrashing;
      default:
        return Sound.silent;
    }
  }
}
