import 'package:open_adventure/domain/value_objects/game_snapshot.dart';

/// Port defining the minimal save/load capabilities required in S2.
abstract class SaveRepository {
  /// Persists the given [snapshot] as the latest autosave.
  Future<void> autosave(GameSnapshot snapshot);

  /// Returns the most recent autosave snapshot, or `null` if none exists.
  Future<GameSnapshot?> latest();
}
