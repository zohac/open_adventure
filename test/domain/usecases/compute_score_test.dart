import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/usecases/compute_score.dart';
import 'package:open_adventure/domain/value_objects/score_breakdown.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAdventureRepository adventureRepository;
  late ComputeScoreImpl useCase;

  setUp(() {
    adventureRepository = _MockAdventureRepository();
    useCase = ComputeScoreImpl(adventureRepository: adventureRepository);
  });

  group('ComputeScoreImpl', () {
    const treasureCarried = GameObjectState(id: 1, isCarried: true);
    const treasureDeposited = GameObjectState(id: 2, location: 99);
    const nonTreasure = GameObjectState(id: 3, location: 5);

    test('awards treasure points for carried and deposited items', () async {
      when(() => adventureRepository.getGameObjects()).thenAnswer(
        (_) async => const <GameObject>[
          GameObject(id: 1, name: 'TREASURE_1', isTreasure: true),
          GameObject(id: 2, name: 'TREASURE_2', isTreasure: true),
          GameObject(id: 3, name: 'ROCK'),
        ],
      );
      when(() => adventureRepository.getLocations()).thenAnswer(
        (_) async => const <Location>[
          Location(id: 99, name: 'LOC_BUILDING'),
          Location(id: 5, name: 'LOC_OTHER'),
        ],
      );

      final Game game = Game(
        loc: 5,
        oldLoc: 5,
        newLoc: 5,
        turns: 0,
        rngSeed: 1234,
        visitedLocations: const <int>{5},
        objectStates: const <int, GameObjectState>{
          1: treasureCarried,
          2: treasureDeposited,
          3: nonTreasure,
        },
      );

      final ScoreBreakdown breakdown = await useCase(game);

      expect(breakdown.treasures, 14);
      expect(breakdown.exploration, 1);
      expect(breakdown.penalties, 0);
      expect(breakdown.total, 15);
    });

    test('caps exploration score and applies turn penalties', () async {
      when(
        () => adventureRepository.getGameObjects(),
      ).thenAnswer((_) async => const <GameObject>[]);
      when(() => adventureRepository.getLocations()).thenAnswer(
        (_) async => const <Location>[Location(id: 99, name: 'LOC_BUILDING')],
      );

      final Set<int> visited = <int>{for (int i = 0; i < 64; i++) i};

      final Game game = Game(
        loc: 0,
        oldLoc: 0,
        newLoc: 0,
        turns: 45,
        rngSeed: 1,
        visitedLocations: visited,
        objectStates: const <int, GameObjectState>{},
      );

      final ScoreBreakdown breakdown = await useCase(game);

      expect(breakdown.treasures, 0);
      expect(breakdown.exploration, 30);
      expect(breakdown.penalties, 4);
      expect(breakdown.total, 26);
    });

    test('ignores unknown treasure states gracefully', () async {
      when(() => adventureRepository.getGameObjects()).thenAnswer(
        (_) async => const <GameObject>[
          GameObject(id: 1, name: 'TREASURE_1', isTreasure: true),
          GameObject(id: 2, name: 'TREASURE_2', isTreasure: true),
        ],
      );
      when(() => adventureRepository.getLocations()).thenAnswer(
        (_) async => const <Location>[Location(id: 99, name: 'LOC_BUILDING')],
      );

      final Game game = Game(
        loc: 0,
        oldLoc: 0,
        newLoc: 0,
        turns: 0,
        rngSeed: 1,
        visitedLocations: const <int>{0},
        objectStates: const <int, GameObjectState>{
          1: GameObjectState(id: 1, isCarried: false),
        },
      );

      final ScoreBreakdown breakdown = await useCase(game);

      expect(breakdown.treasures, 0);
      expect(breakdown.exploration, 1);
      expect(breakdown.penalties, 0);
    });
  });
}
