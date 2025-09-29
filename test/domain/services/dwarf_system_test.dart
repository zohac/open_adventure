import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_adventure/domain/entities/dwarf_state.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/dwarf_system.dart';

class _MockAdventureRepository extends Mock implements AdventureRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue('');
  });

  late _MockAdventureRepository repository;
  late DwarfSystem system;

  setUp(() {
    repository = _MockAdventureRepository();
    system = DwarfSystem(repository);
    when(() => repository.arbitraryMessage(any(), count: any(named: 'count')))
        .thenAnswer((invocation) async {
      final String key = invocation.positionalArguments.first as String;
      final int? count = invocation.namedArguments[#count] as int?;
      switch (key) {
        case 'DWARF_RAN':
          return 'A little dwarf just walked around a corner, saw you, threw '
              'a little axe at you which missed, cursed, and ran away.';
        case 'DWARF_SINGLE':
          return 'There is a threatening little dwarf in the room with you!';
        case 'DWARF_PACK':
          return 'There are ${count ?? 0} threatening little dwarves in the '
              'room with you!';
        case 'KNIFE_THROWN':
          return 'One sharp nasty knife is thrown at you!';
        case 'MISSES_YOU':
          return 'It misses!';
        default:
          return key;
      }
    });
  });

  test('tick outside deep areas leaves state untouched', () async {
    when(() => repository.locationById(any())).thenAnswer(
      (_) async => const Location(
        id: 1,
        name: 'LOC_START',
        conditions: {'DEEP': false},
      ),
    );

    const game = Game(
      loc: 1,
      oldLoc: 1,
      newLoc: 1,
      turns: 0,
      rngSeed: 1234,
    );

    final result = await system.tick(game);

    expect(result.messages, isEmpty);
    expect(result.game.dwarfState, const DwarfState());
    expect(result.game.rngSeed, equals(game.rngSeed));
  });

  test('first deep encounter activates dwarves and emits intro message',
      () async {
    when(() => repository.locationById(any())).thenAnswer(
      (_) async => const Location(
        id: 10,
        name: 'LOC_HALL_OF_MISTS',
        conditions: {'DEEP': true},
      ),
    );

    const game = Game(
      loc: 10,
      oldLoc: 10,
      newLoc: 10,
      turns: 0,
      rngSeed: 42,
    );

    final result = await system.tick(game);

    expect(result.messages, hasLength(1));
    expect(result.messages.first, startsWith('A little dwarf just walked'));
    expect(result.game.dwarfState.activated, isTrue);
    expect(result.game.dwarfState.dwarfLocations.first, equals(game.loc));
  });

  test('ticks are deterministic for a fixed seed', () async {
    when(() => repository.locationById(any())).thenAnswer(
      (_) async => const Location(
        id: 20,
        name: 'LOC_TWISTY_PASSAGES',
        conditions: {'DEEP': true},
      ),
    );

    const initialGame = Game(
      loc: 20,
      oldLoc: 20,
      newLoc: 20,
      turns: 0,
      rngSeed: 99,
    );

    final sequenceA = await _simulate(system, initialGame, 5);
    final sequenceB = await _simulate(system, initialGame, 5);

    expect(sequenceA, equals(sequenceB));
  });
}

Future<List<List<String>>> _simulate(
  DwarfSystem system,
  Game start,
  int iterations,
) async {
  var current = start;
  final List<List<String>> snapshots = <List<String>>[];
  for (var i = 0; i < iterations; i++) {
    final tick = await system.tick(current);
    snapshots.add(tick.messages);
    current = tick.game;
  }
  return snapshots;
}
