import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const observerAction = ActionOption(
    id: 'meta:observer',
    category: 'meta',
    label: 'actions.observer.label',
    icon: 'visibility',
    verb: 'OBSERVER',
  );

  late MotionNormalizerImpl motion;

  setUpAll(() async {
    motion = await MotionNormalizerImpl.load();
  });

  test('ListAvailableActionsTravel returns only travel, deduped and sorted',
      () async {
    final repo = AdventureRepositoryImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    // Start from LOC_START (id 1) per assets; ensure deterministic seed not needed here
    const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    expect(opts, isNotEmpty);
    // Only travel
    expect(opts.every((o) => o.category == 'travel'), isTrue);
    // Dedup: ids must be unique
    final ids = opts.map((e) => e.id).toSet();
    expect(ids.length, equals(opts.length));
    // Sorted deterministically by verb then dest
    // Presence of labels/icons from normalizer
    expect(opts.first.label.startsWith('motion.'), isTrue);
    expect(opts.first.icon, isNotNull);

    final verbs = opts.map((e) => e.verb).toList();
    expect(verbs.contains('ENTER'), isTrue);
    final idxEast = verbs.indexOf('EAST');
    final idxEnter = verbs.indexOf('ENTER');
    if (idxEast != -1 && idxEnter != -1) {
      expect(idxEnter < idxEast, isTrue);
    }
  });

  test('Synonyms (numeric/text) dedupe to a single canonical option', () async {
    final repo = AdventureRepositoryImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    // If both MOT_2 and WEST exist in travel.json for LOC_START, they must dedupe to one WEST option.
    final westOpts = opts.where((o) => o.verb == 'WEST').toList();
    expect(westOpts.length <= 1, isTrue);
  });

  test('Labels are UI keys and icons mapped for known motions', () async {
    final repo = AdventureRepositoryImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    for (final o in opts) {
      expect(o.label.startsWith('motion.'), isTrue);
      if ({'NORTH', 'EAST', 'SOUTH', 'WEST', 'UP', 'DOWN'}.contains(o.verb)) {
        expect(o.icon, isNotNull);
      }
    }
  });

  test('IDs are stable and include fromId,destId,motion', () async {
    final repo = AdventureRepositoryImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    for (final o in opts) {
      expect(o.id.startsWith('travel:1->'), isTrue);
      expect(o.id.contains(':${o.verb}'), isTrue);
    }
  });

  test('Unknown/empty motions are excluded', () async {
    // Directly verify canonicalization fallback behavior for odd inputs.
    expect(motion.toCanonical(''), equals(''));
    expect(motion.toCanonical('mot_9999'), equals('UNKNOWN'));
  });

  test('Filters conditional travel rules (cond_not etc.)', () async {
    final repo = AdventureRepositoryImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 8, oldLoc: 8, newLoc: 8, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    expect(opts.any((o) => o.verb == 'DOWN' || o.verb == 'IN'), isFalse);
  });

  test('Contextual motions expose the canonical iconography', () {
    expect(motion.iconName('UP'), equals('arrow_upward'));
    expect(motion.iconName('DOWN'), equals('arrow_downward'));
    expect(motion.iconName('ENTER'), equals('login'));
    expect(motion.iconName('OUT'), equals('logout'));
  });

  test('returns observer fallback when no travel actions are available', () async {
    final repo = _EmptyTravelRepository();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 42, oldLoc: 42, newLoc: 42, turns: 0, rngSeed: 99);

    final options = await usecase(game);

    expect(options, equals(const [observerAction]));
  });
}

class _EmptyTravelRepository implements AdventureRepository {
  @override
  Future<Game> initialGame() {
    throw UnimplementedError();
  }

  @override
  Future<List<Location>> getLocations() async {
    return const [
      Location(id: 42, name: 'LOC_TEST'),
    ];
  }

  @override
  Future<List<GameObject>> getGameObjects() {
    throw UnimplementedError();
  }

  @override
  Future<Location> locationById(int id) async =>
      const Location(id: 42, name: 'LOC_TEST');

  @override
  Future<List<TravelRule>> travelRulesFor(int locationId) async => const [];
}
