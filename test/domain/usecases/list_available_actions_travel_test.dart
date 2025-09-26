import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

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

  test('includes BACK option when history allows it', () async {
    final repo = _MockAdventureRepository();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(
      loc: 5,
      oldLoc: 4,
      oldLc2: 3,
      newLoc: 5,
      turns: 2,
      rngSeed: 11,
    );

    when(() => repo.travelRulesFor(5)).thenAnswer((_) async => const []);
    when(() => repo.locationById(5))
        .thenAnswer((_) async => const Location(id: 5, name: 'LOC_FIVE'));
    when(() => repo.locationById(4))
        .thenAnswer((_) async => const Location(id: 4, name: 'LOC_FOUR'));

    final options = await usecase(game);

    expect(options, hasLength(1));
    final back = options.single;
    expect(back.verb, 'BACK');
    expect(back.label, 'actions.travel.back');
    expect(back.objectId, '4');
    expect(back.icon, 'undo');
  });

  test('BACK option uses oldLc2 when previous location is forced', () async {
    final repo = _MockAdventureRepository();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(
      loc: 7,
      oldLoc: 6,
      oldLc2: 2,
      newLoc: 7,
      turns: 4,
      rngSeed: 3,
    );

    when(() => repo.travelRulesFor(7)).thenAnswer((_) async => const []);
    when(() => repo.locationById(7))
        .thenAnswer((_) async => const Location(id: 7, name: 'LOC_SEVEN'));
    when(() => repo.locationById(6)).thenAnswer((_) async =>
        const Location(id: 6, name: 'LOC_FORCED', conditions: {'FORCED': true}));
    when(() => repo.locationById(2))
        .thenAnswer((_) async => const Location(id: 2, name: 'LOC_SAFE'));

    final options = await usecase(game);
    final back = options.singleWhere((option) => option.verb == 'BACK');
    expect(back.objectId, '2');
  });

  test('does not offer BACK when current location forbids it', () async {
    final repo = _MockAdventureRepository();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(
      loc: 9,
      oldLoc: 8,
      oldLc2: 1,
      newLoc: 9,
      turns: 6,
      rngSeed: 5,
    );

    when(() => repo.travelRulesFor(9)).thenAnswer((_) async => const []);
    when(() => repo.locationById(9)).thenAnswer((_) async =>
        const Location(id: 9, name: 'LOC_BLOCK', conditions: {'NOBACK': true}));

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
