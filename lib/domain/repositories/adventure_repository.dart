import '../entities/game.dart';
import '../entities/location.dart';
import '../entities/travel_rule.dart';
import '../entities/game_object.dart';

/// Port exposing the adventure data and initial state to the domain.
abstract class AdventureRepository {
  /// Builds the initial game state from assets with deterministic RNG seed (42 in S1).
  Future<Game> initialGame();

  /// Returns all locations parsed from assets with sequential ids.
  Future<List<Location>> getLocations();

  /// Returns all game objects parsed from assets with sequential ids.
  Future<List<GameObject>> getGameObjects();

  /// Returns a location by its numeric identifier.
  Future<Location> locationById(int id);

  /// Returns travel rules for the given source location id.
  Future<List<TravelRule>> travelRulesFor(int locationId);

  /// Returns a formatted arbitrary message identified by [key].
  Future<String> arbitraryMessage(String key, {int? count});
}
