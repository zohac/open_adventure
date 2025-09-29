import 'package:open_adventure/domain/entities/dwarf_state.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/dwarf_tick_result.dart';

/// Domain service orchestrating dwarf encounters each turn.
class DwarfSystem {
  /// Creates a [DwarfSystem] tied to the [AdventureRepository].
  const DwarfSystem(this._adventureRepository);

  final AdventureRepository _adventureRepository;

  static const int _dwarfSlots = 3;

  /// Advances the dwarf simulation and returns the resulting state/messages.
  Future<DwarfTickResult> tick(Game game) async {
    final location = await _adventureRepository.locationById(game.loc);
    final bool isDeep = location.conditions['DEEP'] ?? false;
    final _Lcg rng = _Lcg(game.rngSeed);

    DwarfState state = game.dwarfState;
    final List<String> messages = <String>[];

    if (!state.activated) {
      if (isDeep) {
        state = _activate(state, game.loc);
        messages.add(await _message('DWARF_RAN'));
      }
    } else if (isDeep) {
      final _MovementOutcome outcome = _moveAndThreaten(state, game.loc, rng);
      state = outcome.state;
      if (outcome.threatCount > 0) {
        messages.add(await _threatMessage(outcome.threatCount));
        if (outcome.triggerAttack) {
          messages.add(await _message('KNIFE_THROWN'));
          messages.add(await _message('MISSES_YOU'));
        }
      }
    } else if (state.dwarfLocations.any((loc) => loc >= 0)) {
      state = state.copyWith(
        dwarfLocations: List<int>.filled(
          state.dwarfLocations.isEmpty
              ? _dwarfSlots
              : state.dwarfLocations.length,
          -1,
        ),
      );
    }

    final Game updatedGame = game.copyWith(
      rngSeed: rng.state,
      dwarfState: state,
    );

    return DwarfTickResult(game: updatedGame, messages: messages);
  }

  DwarfState _activate(DwarfState state, int playerLocation) {
    final List<int> slots = state.dwarfLocations.isNotEmpty
        ? List<int>.from(state.dwarfLocations)
        : List<int>.filled(_dwarfSlots, -1);
    if (slots.length < _dwarfSlots) {
      slots.addAll(List<int>.filled(_dwarfSlots - slots.length, -1));
    }
    slots[0] = playerLocation;
    return state.copyWith(
      activated: true,
      introShown: true,
      dwarfLocations: slots,
    );
  }

  _MovementOutcome _moveAndThreaten(
    DwarfState state,
    int playerLocation,
    _Lcg rng,
  ) {
    final List<int> current = state.dwarfLocations.isNotEmpty
        ? List<int>.from(state.dwarfLocations)
        : List<int>.filled(_dwarfSlots, -1);
    if (current.length < _dwarfSlots) {
      current.addAll(List<int>.filled(_dwarfSlots - current.length, -1));
    }

    final List<int> updated = <int>[];
    var threats = 0;

    for (final loc in current) {
      final int roll = rng.nextInt(100);
      final int newLocation;
      if (loc == playerLocation) {
        newLocation = roll < 70 ? playerLocation : -1;
      } else {
        newLocation = roll < 40 ? playerLocation : -1;
      }
      updated.add(newLocation);
      if (newLocation == playerLocation) {
        threats++;
      }
    }

    final bool attack = threats > 0 && rng.nextInt(100) < 35;

    return _MovementOutcome(
      state.copyWith(dwarfLocations: updated),
      threats,
      attack,
    );
  }

  Future<String> _message(String key, {int? count}) =>
      _adventureRepository.arbitraryMessage(key, count: count);

  Future<String> _threatMessage(int count) => _message(
    count > 1 ? 'DWARF_PACK' : 'DWARF_SINGLE',
    count: count > 1 ? count : null,
  );
}

class _MovementOutcome {
  const _MovementOutcome(this.state, this.threatCount, this.triggerAttack);

  final DwarfState state;
  final int threatCount;
  final bool triggerAttack;
}

class _Lcg {
  _Lcg(int seed) : state = seed % _m {
    if (state < 0) {
      state += _m;
    }
  }

  static const int _m = 1048576;
  static const int _a = 1093;
  static const int _c = 221587;

  int state;

  int nextInt(int range) {
    if (range <= 0) {
      return 0;
    }
    final int value = state;
    state = (_a * state + _c) % _m;
    return (range * value) ~/ _m;
  }
}
