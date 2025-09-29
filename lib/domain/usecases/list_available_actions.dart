import 'package:open_adventure/domain/constants/interaction_requirements.dart';
import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/services/motion_canonicalizer.dart';
import 'package:open_adventure/domain/usecases/evaluate_condition.dart';
import 'package:open_adventure/domain/value_objects/action_option.dart';
import 'package:open_adventure/domain/value_objects/magic_words.dart';
import 'package:open_adventure/domain/value_objects/condition.dart';

/// Liste complète des actions disponibles (travel + interactions + méta).
class ListAvailableActions {
  /// Crée un orchestrateur combinant déplacements, interactions et méta-actions.
  ListAvailableActions({
    required AdventureRepository adventureRepository,
    required ListAvailableActionsTravel travel,
    required EvaluateCondition evaluateCondition,
  }) : _adventureRepository = adventureRepository,
       _travel = travel,
       _evaluateCondition = evaluateCondition;

  final AdventureRepository _adventureRepository;
  final ListAvailableActionsTravel _travel;
  final EvaluateCondition _evaluateCondition;

  static const List<ActionOption> _metaActions = <ActionOption>[
    ActionOption(
      id: 'meta:inventory',
      category: 'meta',
      label: 'actions.inventory.label',
      icon: 'inventory',
      verb: 'INVENTORY',
    ),
    ActionOption(
      id: 'meta:observer',
      category: 'meta',
      label: 'actions.observer.label',
      icon: 'visibility',
      verb: 'OBSERVER',
    ),
    ActionOption(
      id: 'meta:map',
      category: 'meta',
      label: 'actions.map.label',
      icon: 'map',
      verb: 'MAP',
    ),
  ];

  /// Retourne les actions disponibles triées par priorité (sécurité → travel → interaction → méta).
  Future<List<ActionOption>> call(Game current) async {
    final List<ActionOption> travelOptions = await _travel(current);
    final List<ActionOption> interactionOptions =
        await _buildInteractionOptions(current);

    final Map<String, _PrioritizedOption> unique =
        <String, _PrioritizedOption>{};
    var sequence = 0;

    void addOption(ActionOption option) {
      unique.putIfAbsent(
        option.id,
        () => _PrioritizedOption(
          option: option,
          priority: _priorityFor(option.category),
          sequence: sequence++,
        ),
      );
    }

    for (final option in travelOptions) {
      addOption(option);
    }
    for (final option in interactionOptions) {
      addOption(option);
    }
    for (final option in _metaActions) {
      addOption(option);
    }

    final sorted = unique.values.toList()
      ..sort((a, b) {
        final priorityCompare = a.priority - b.priority;
        if (priorityCompare != 0) {
          return priorityCompare;
        }
        if (a.option.category == 'travel' && b.option.category == 'travel') {
          return a.sequence - b.sequence;
        }
        final labelCompare = a.option.label.compareTo(b.option.label);
        if (labelCompare != 0) {
          return labelCompare;
        }
        final objectCompare = (a.option.objectId ?? '').compareTo(
          b.option.objectId ?? '',
        );
        if (objectCompare != 0) {
          return objectCompare;
        }
        return a.sequence - b.sequence;
      });

    return List<ActionOption>.unmodifiable(sorted.map((entry) => entry.option));
  }

  Future<List<ActionOption>> _buildInteractionOptions(Game game) async {
    if (game.objectStates.isEmpty) {
      return const <ActionOption>[];
    }

    final List<GameObject> objects = await _adventureRepository
        .getGameObjects();
    final Map<int, GameObject> index = <int, GameObject>{
      for (final object in objects) object.id: object,
    };

    final List<ActionOption> options = <ActionOption>[];

    for (final state in game.objectStates.values) {
      final GameObject? object = index[state.id];
      if (object == null) {
        continue;
      }
      final bool isVisible = _evaluateCondition(
        Condition.withObject(objectId: state.id),
        game,
      );
      if (!isVisible) {
        continue;
      }
      final String objectId = object.id.toString();
      final String keySuffix = object.name;

      options.add(
        ActionOption(
          id: 'interaction:examine:$objectId',
          category: 'interaction',
          label: 'actions.interaction.examine.$keySuffix',
          icon: 'search',
          verb: 'EXAMINE',
          objectId: objectId,
        ),
      );

      final bool isCarried = _evaluateCondition(
        Condition.carry(objectId: state.id),
        game,
      );

      if (isCarried) {
        options.add(
          ActionOption(
            id: 'interaction:drop:$objectId',
            category: 'interaction',
            label: 'actions.interaction.drop.$keySuffix',
            icon: 'file_upload',
            verb: 'DROP',
            objectId: objectId,
          ),
        );
      } else {
        final bool isTakeable =
            !object.immovable &&
            _evaluateCondition(
              Condition.not(Condition.carry(objectId: state.id)),
              game,
            );

        if (isTakeable) {
          options.add(
            ActionOption(
              id: 'interaction:take:$objectId',
              category: 'interaction',
              label: 'actions.interaction.take.$keySuffix',
              icon: 'file_download',
              verb: 'TAKE',
              objectId: objectId,
            ),
          );
        }
      }

      if (object.name == 'LAMP') {
        options.addAll(
          _buildLampActions(
            object: object,
            state: state,
            game: game,
          ),
        );
      }

      if (object.name == 'BOTTLE') {
        options.addAll(
          _buildBottleActions(
            object: object,
            state: state,
            game: game,
          ),
        );
      }

      final ActionOption? openAction = _buildOpenAction(
        object: object,
        state: state,
        game: game,
      );
      if (openAction != null) {
        options.add(openAction);
      }

      final ActionOption? closeAction = _buildCloseAction(
        object: object,
        state: state,
        game: game,
      );
      if (closeAction != null) {
        options.add(closeAction);
      }
    }

    options.sort((a, b) {
      final labelCompare = a.label.compareTo(b.label);
      if (labelCompare != 0) {
        return labelCompare;
      }
      final objectCompare = (a.objectId ?? '').compareTo(b.objectId ?? '');
      if (objectCompare != 0) {
        return objectCompare;
      }
      return a.id.compareTo(b.id);
    });

    return options;
  }

  List<ActionOption> _buildLampActions({
    required GameObject object,
    required GameObjectState state,
    required Game game,
  }) {
    final List<String>? definedStates = object.states;
    if (definedStates == null || definedStates.isEmpty) {
      return const <ActionOption>[];
    }

    final int brightIndex = _indexWhere(
      definedStates,
      (value) => value.contains('BRIGHT'),
    );
    final int darkIndex = _indexWhere(
      definedStates,
      (value) => value.contains('DARK'),
    );
    if (brightIndex == -1 || darkIndex == -1) {
      return const <ActionOption>[];
    }

    final String brightStateValue = definedStates[brightIndex];
    final bool isAccessible = state.isCarried || state.isAt(game.loc);
    if (!isAccessible) {
      return const <ActionOption>[];
    }

    final List<ActionOption> lampOptions = <ActionOption>[];
    final bool isLit = _evaluateCondition(
      Condition.state(objectId: object.id, value: brightStateValue),
      game,
    );
    if (!isLit && game.limit > 0) {
      lampOptions.add(
        ActionOption(
          id: 'interaction:light:${object.id}',
          category: 'interaction',
          label: 'actions.interaction.light.${object.name}',
          icon: 'flash_on',
          verb: 'LIGHT',
          objectId: object.id.toString(),
        ),
      );
    }

    if (isLit) {
      lampOptions.add(
        ActionOption(
          id: 'interaction:extinguish:${object.id}',
          category: 'interaction',
          label: 'actions.interaction.extinguish.${object.name}',
          icon: 'flash_off',
          verb: 'EXTINGUISH',
          objectId: object.id.toString(),
        ),
      );
    }

    return lampOptions;
  }

  List<ActionOption> _buildBottleActions({
    required GameObject object,
    required GameObjectState state,
    required Game game,
  }) {
    final List<String>? definedStates = object.states;
    if (definedStates == null || definedStates.isEmpty) {
      return const <ActionOption>[];
    }

    final int waterIndex = _indexWhere(
      definedStates,
      (value) => value.contains('WATER'),
    );
    if (waterIndex == -1) {
      return const <ActionOption>[];
    }

    final bool isAccessible = state.isCarried || state.isAt(game.loc);
    if (!isAccessible) {
      return const <ActionOption>[];
    }

    final bool hasWater = _evaluateCondition(
      Condition.state(objectId: object.id, value: definedStates[waterIndex]),
      game,
    );
    if (!hasWater) {
      return const <ActionOption>[];
    }

    return <ActionOption>[
      ActionOption(
        id: 'interaction:drink:${object.id}',
        category: 'interaction',
        label: 'actions.interaction.drink.${object.name}',
        icon: 'local_drink',
        verb: 'DRINK',
        objectId: object.id.toString(),
      ),
    ];
  }

  static int _priorityFor(String category) {
    switch (category) {
      case 'security':
        return 0;
      case 'travel':
        return 1;
      case 'interaction':
        return 2;
      case 'meta':
        return 3;
      default:
        return 4;
    }
  }

  ActionOption? _buildOpenAction({
    required GameObject object,
    required GameObjectState state,
    required Game game,
  }) {
    final List<String>? definedStates = object.states;
    if (definedStates == null || definedStates.isEmpty) {
      return null;
    }

    final int openIndex = _indexWhere(
      definedStates,
      (value) => value.contains('OPEN'),
    );
    if (openIndex == -1) {
      return null;
    }

    final String openStateValue = definedStates[openIndex];
    final bool alreadyOpen = _evaluateCondition(
      Condition.state(objectId: object.id, value: openStateValue),
      game,
    );
    if (alreadyOpen) {
      return null;
    }

    final bool isAccessible = state.isCarried || state.isAt(game.loc);
    if (!isAccessible) {
      return null;
    }

    final int? requiredKeyId = kOpenObjectRequiredKeys[object.name];
    if (requiredKeyId != null) {
      final bool hasKey = _evaluateCondition(
        Condition.carry(objectId: requiredKeyId),
        game,
      );
      if (!hasKey) {
        return null;
      }
    }

    return ActionOption(
      id: 'interaction:open:${object.id}',
      category: 'interaction',
      label: 'actions.interaction.open.${object.name}',
      icon: 'lock_open',
      verb: 'OPEN',
      objectId: object.id.toString(),
    );
  }

  ActionOption? _buildCloseAction({
    required GameObject object,
    required GameObjectState state,
    required Game game,
  }) {
    final List<String>? definedStates = object.states;
    if (definedStates == null || definedStates.isEmpty) {
      return null;
    }

    final int closeIndex = _indexWhere(
      definedStates,
      (value) => value.contains('CLOSE'),
    );
    if (closeIndex == -1) {
      return null;
    }

    final String closeStateValue = definedStates[closeIndex];
    final bool alreadyClosed = _evaluateCondition(
      Condition.state(objectId: object.id, value: closeStateValue),
      game,
    );
    if (alreadyClosed) {
      return null;
    }

    final bool isAccessible = state.isCarried || state.isAt(game.loc);
    if (!isAccessible) {
      return null;
    }

    return ActionOption(
      id: 'interaction:close:${object.id}',
      category: 'interaction',
      label: 'actions.interaction.close.${object.name}',
      icon: 'lock',
      verb: 'CLOSE',
      objectId: object.id.toString(),
    );
  }

  int _indexWhere(List<String> values, bool Function(String) predicate) {
    for (var index = 0; index < values.length; index++) {
      if (predicate(values[index])) {
        return index;
      }
    }
    return -1;
  }
}

/// ListAvailableActions (travel only) — calcule les options de déplacement.
class ListAvailableActionsTravel {
  final AdventureRepository _repo;
  final MotionCanonicalizer _motion;
  const ListAvailableActionsTravel(this._repo, this._motion);

  /// Retourne uniquement des options `category=travel` pour l'état courant.
  Future<List<ActionOption>> call(Game current) async {
    final rules = await _repo.travelRulesFor(current.loc);
    final candidates = <String, _TravelCandidate>{};
    Map<String, int>? nameToId;
    final currentLocation = await _repo.locationById(current.loc);
    for (final r in rules) {
      final canonical = _motion.toCanonical(r.motion);
      if (canonical.isEmpty || canonical == 'UNKNOWN') continue;
      if (!current.magicWordsUnlocked && MagicWords.isIncantation(canonical)) {
        continue;
      }
      var destId = r.destId;
      if (destId == null) {
        nameToId ??= {for (final l in await _repo.getLocations()) l.name: l.id};
        final destName = r.destName;
        if (destName.isEmpty) continue;
        destId = nameToId[destName];
      }
      if (destId == null) continue;
      final candidate = _TravelCandidate(
        canonical: canonical,
        label: _motion.uiKey(canonical),
        icon: _motion.iconName(canonical),
        priority: _motion.priority(canonical),
        destId: destId,
      );
      final key = '${destId}_$canonical';
      final currentBest = candidates[key];
      if (currentBest == null || candidate.compareTo(currentBest) < 0) {
        candidates[key] = candidate;
      }
    }

    final options = candidates.values
        .map(
          (c) => ActionOption(
            id: 'travel:${current.loc}->${c.destId}:${c.canonical}',
            category: 'travel',
            label: c.label,
            icon: c.icon,
            verb: c.canonical,
            objectId: c.destId.toString(),
          ),
        )
        .toList();

    final backTarget = await _resolveBackTarget(current, currentLocation);
    if (backTarget != null) {
      options.add(
        ActionOption(
          id: 'travel:${current.loc}->$backTarget:BACK',
          category: 'travel',
          label: 'actions.travel.back',
          icon: _motion.iconName('BACK'),
          verb: 'BACK',
          objectId: backTarget.toString(),
        ),
      );
    }

    options.sort((a, b) {
      final pa = _motion.priority(a.verb);
      final pb = _motion.priority(b.verb);
      if (pa != pb) return pa - pb;
      final cl = a.label.compareTo(b.label);
      if (cl != 0) return cl;
      final da = int.tryParse(a.objectId ?? '') ?? 0;
      final db = int.tryParse(b.objectId ?? '') ?? 0;
      return da - db;
    });
    if (options.isEmpty) {
      return const [
        ActionOption(
          id: 'meta:observer',
          category: 'meta',
          label: 'actions.observer.label',
          icon: 'visibility',
          verb: 'OBSERVER',
        ),
      ];
    }

    return options;
  }

  Future<int?> _resolveBackTarget(
    Game current,
    Location currentLocation,
  ) async {
    if (current.oldLoc == current.loc) {
      return null;
    }
    if (currentLocation.conditions['NOBACK'] == true) {
      return null;
    }

    final int candidate = current.oldLoc;
    final Location previousLocation;
    try {
      previousLocation = await _repo.locationById(candidate);
    } catch (_) {
      return null;
    }
    final bool previousForced = previousLocation.conditions['FORCED'] == true;
    final int resolved = previousForced ? current.oldLc2 : candidate;
    if (resolved == current.loc) {
      return null;
    }
    try {
      await _repo.locationById(resolved);
    } catch (_) {
      return null;
    }
    return resolved;
  }
}

class _TravelCandidate {
  final String canonical;
  final String label;
  final String? icon;
  final int priority;
  final int destId;

  const _TravelCandidate({
    required this.canonical,
    required this.label,
    required this.icon,
    required this.priority,
    required this.destId,
  });

  int compareTo(_TravelCandidate other) {
    if (priority != other.priority) {
      return priority - other.priority;
    }
    final labelComparison = label.compareTo(other.label);
    if (labelComparison != 0) {
      return labelComparison;
    }
    return destId - other.destId;
  }
}

class _PrioritizedOption {
  const _PrioritizedOption({
    required this.option,
    required this.priority,
    required this.sequence,
  });

  final ActionOption option;
  final int priority;
  final int sequence;
}
