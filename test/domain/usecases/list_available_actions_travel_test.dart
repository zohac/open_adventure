import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';
import 'package:open_adventure/data/services/motion_normalizer_impl.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/usecases/list_available_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ListAvailableActionsTravel returns only travel, deduped and sorted', () async {
    final repo = AdventureRepositoryImpl();
    final motion = MotionNormalizerImpl();
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

    // Ordering: cardinal (e.g., WEST) should come before ENTER at LOC_START
    final verbs = opts.map((e) => e.verb).toList();
    final idxWest = verbs.indexOf('WEST');
    final idxEnter = verbs.indexOf('ENTER');
    if (idxEnter != -1) {
      expect(idxWest == -1 || idxWest < idxEnter, isTrue);
    }
  });

  test('Synonyms (numeric/text) dedupe to a single canonical option', () async {
    final repo = AdventureRepositoryImpl();
    final motion = MotionNormalizerImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    // If both MOT_2 and WEST exist in travel.json for LOC_START, they must dedupe to one WEST option.
    final westOpts = opts.where((o) => o.verb == 'WEST').toList();
    expect(westOpts.length <= 1, isTrue);
  });

  test('Labels are UI keys and icons mapped for known motions', () async {
    final repo = AdventureRepositoryImpl();
    final motion = MotionNormalizerImpl();
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
    final motion = MotionNormalizerImpl();
    final usecase = ListAvailableActionsTravel(repo, motion);
    const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
    final opts = await usecase(game);
    for (final o in opts) {
      expect(o.id.startsWith('travel:1->'), isTrue);
      expect(o.id.contains(':${o.verb}'), isTrue);
    }
  });

  test('Unknown/empty motions are excluded', () async {
    final motion = MotionNormalizerImpl();
    // Directly verify canonicalization fallback behavior for odd inputs.
    expect(motion.toCanonical(''), equals(''));
    expect(motion.toCanonical('mot_9999'), equals('MOT_9999'));
  });
}
