import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initialGame builds a valid initial state with seed 42', () async {
    final repo = AdventureRepositoryImpl();
    final game = await repo.initialGame();
    final locs = await repo.getLocations();
    expect(game.rngSeed, 42);
    expect(game.turns, 0);
    expect(game.loc, inInclusiveRange(0, locs.length - 1));
    expect(game.oldLoc, game.loc);
    expect(game.newLoc, game.loc);
    expect(game.visitedLocations, {game.loc});
    expect(game.objectStates, isNotEmpty);

    final int? buildingId = repo.locationIdForName('LOC_BUILDING');
    final int? keysId = repo.objectIdForName('KEYS');
    final int? lampId = repo.objectIdForName('LAMP');
    expect(buildingId, isNotNull);
    expect(keysId, isNotNull);
    expect(lampId, isNotNull);
    final keysState = game.objectStates[keysId!];
    final lampState = game.objectStates[lampId!];
    expect(keysState?.location, buildingId);
    expect(keysState?.isCarried, isFalse);
    expect(lampState?.location, buildingId);
    expect(lampState?.isCarried, isFalse);
  });
}
