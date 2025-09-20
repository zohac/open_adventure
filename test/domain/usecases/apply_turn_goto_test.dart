import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/entities/travel_rule.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/usecases/apply_turn_goto.dart';
import 'package:open_adventure/domain/value_objects/command.dart';

class MockAdventureRepository extends Mock implements AdventureRepository {}

class MockMotionCanonicalizer extends Mock implements MotionCanonicalizer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAdventureRepository mockRepo;
  late MockMotionCanonicalizer mockMotion;
  late ApplyTurnGoto usecase;

  setUp(() {
    mockRepo = MockAdventureRepository();
    mockMotion = MockMotionCanonicalizer();
    usecase = ApplyTurnGoto(mockRepo, mockMotion);

    when(() => mockMotion.toCanonical(any())).thenAnswer((invocation) {
      final verb = invocation.positionalArguments[0] as String;
      if (verb == 'WEST' || verb == 'MOT_2') return 'WEST';
      if (verb == 'WEST_ALT') return 'WEST';
      return verb;
    });
  });

  group('ApplyTurnGoto', () {
    test('updates location, increments turns and returns description', () async {
      final currentLocation = Location(id: 1, name: 'LOC_START');
      final destinationLocation = Location(
        id: 2,
        name: 'LOC_WEST',
        shortDescription: 'A short description of the west.',
        longDescription: 'A very long and detailed description of the west.',
      );
      final travelRule = TravelRule(
        fromId: 1,
        motion: 'WEST',
        destName: 'LOC_WEST',
        destId: 2,
      );

      when(() => mockRepo.locationById(1)).thenAnswer((_) async => currentLocation);
      when(() => mockRepo.locationById(2)).thenAnswer((_) async => destinationLocation);
      when(() => mockRepo.travelRulesFor(1)).thenAnswer((_) async => [travelRule]);

      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'WEST', target: '2');

      final result = await usecase(cmd, game);

      expect(result.newGame.loc, 2);
      expect(result.newGame.oldLoc, 1);
      expect(result.newGame.newLoc, 2);
      expect(result.newGame.turns, 1);
      expect(result.newGame.visitedLocations, {2}); // First visit, so only 2 is visited
      expect(result.messages, [destinationLocation.longDescription]);
    });

    test('returns short description on revisit', () async {
      final currentLocation = Location(id: 1, name: 'LOC_START');
      final destinationLocation = Location(
        id: 2,
        name: 'LOC_WEST',
        shortDescription: 'A short description of the west.',
        longDescription: 'A very long and detailed description of the west.',
      );
      final travelRule = TravelRule(
        fromId: 1,
        motion: 'WEST',
        destName: 'LOC_WEST',
        destId: 2,
      );

      when(() => mockRepo.locationById(1)).thenAnswer((_) async => currentLocation);
      when(() => mockRepo.locationById(2)).thenAnswer((_) async => destinationLocation);
      when(() => mockRepo.travelRulesFor(1)).thenAnswer((_) async => [travelRule]);

      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42, visitedLocations: {2}); // Location 2 already visited
      final cmd = Command(verb: 'WEST', target: '2');

      final result = await usecase(cmd, game);

      expect(result.newGame.loc, 2);
      expect(result.newGame.visitedLocations, {2}); // Still only 2 visited
      expect(result.messages, [destinationLocation.shortDescription]);
    });

    test('uses the first matching travel rule when multiples resolve', () async {
      final currentLocation = Location(id: 1, name: 'LOC_START');
      final destinationLocation = Location(
        id: 2,
        name: 'LOC_WEST',
        shortDescription: 'Short WEST',
        longDescription: 'Long WEST',
      );
      final firstRule = TravelRule(
        fromId: 1,
        motion: 'WEST',
        destName: 'LOC_WEST',
        destId: 2,
      );
      final secondRule = TravelRule(
        fromId: 1,
        motion: 'WEST_ALT',
        destName: 'LOC_WEST',
        destId: 2,
      );

      when(() => mockRepo.locationById(1)).thenAnswer((_) async => currentLocation);
      when(() => mockRepo.locationById(2)).thenAnswer((_) async => destinationLocation);
      when(() => mockRepo.travelRulesFor(1)).thenAnswer((_) async => [firstRule, secondRule]);

      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'WEST', target: '2');

      final result = await usecase(cmd, game);

      expect(result.newGame.loc, 2);
      expect(result.newGame.turns, 1);
      expect(result.messages.first.isNotEmpty, isTrue);
      verifyNever(() => mockMotion.toCanonical('WEST_ALT'));
    });

    test('canonicalizes command verb aliases', () async {
      final currentLocation = Location(id: 1, name: 'LOC_START');
      final destinationLocation = Location(id: 2, name: 'LOC_WEST');
      final travelRule = TravelRule(
        fromId: 1,
        motion: 'WEST',
        destName: 'LOC_WEST',
        destId: 2,
      );

      when(() => mockRepo.locationById(1)).thenAnswer((_) async => currentLocation);
      when(() => mockRepo.locationById(2)).thenAnswer((_) async => destinationLocation);
      when(() => mockRepo.travelRulesFor(1)).thenAnswer((_) async => [travelRule]);

      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'MOT_2', target: '2'); // MOT_2 is an alias for WEST

      final result = await usecase(cmd, game);

      expect(result.newGame.loc, 2);
    });

    test('throws StateError when no matching rule', () async {
      final currentLocation = Location(id: 1, name: 'LOC_START');
      final destinationLocation = Location(id: 2, name: 'LOC_WEST');
      when(() => mockRepo.locationById(1)).thenAnswer((_) async => currentLocation);
      when(() => mockRepo.locationById(2)).thenAnswer((_) async => destinationLocation);
      when(() => mockRepo.travelRulesFor(1)).thenAnswer((_) async => []); // No travel rules

      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'FOO', target: '2');

      expect(() => usecase(cmd, game), throwsA(isA<StateError>()));
    });

    test('throws StateError for invalid destination ID', () async {
      const game = Game(loc: 1, oldLoc: 1, newLoc: 1, turns: 0, rngSeed: 42);
      final cmd = Command(verb: 'WEST', target: 'invalid');

      expect(() => usecase(cmd, game), throwsA(isA<StateError>()));
    });
  });
}
