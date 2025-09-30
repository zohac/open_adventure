import 'dart:math';

import 'package:open_adventure/domain/entities/game.dart';
import 'package:open_adventure/domain/entities/game_object.dart';
import 'package:open_adventure/domain/entities/game_object_state.dart';
import 'package:open_adventure/domain/entities/location.dart';
import 'package:open_adventure/domain/repositories/adventure_repository.dart';
import 'package:open_adventure/domain/value_objects/score_breakdown.dart';

/// Contrat Domain pour calculer un score partiel.
abstract class ComputeScore {
  /// Calcule le [ScoreBreakdown] courant pour l'état [game].
  Future<ScoreBreakdown> call(Game game);
}

/// Implémentation partielle de [ComputeScore] couvrant trésors/exploration/pénalités.
class ComputeScoreImpl implements ComputeScore {
  /// Crée un use case `ComputeScore` basé sur les assets d'[AdventureRepository].
  ComputeScoreImpl({
    required AdventureRepository adventureRepository,
    this.scoringLocationNames = const <String>{'LOC_BUILDING'},
    this.treasureFoundPoints = 2,
    this.treasureDepositBonus = 10,
    this.explorationPointPerLocation = 1,
    this.explorationCap = 30,
    this.turnPenaltyInterval = 20,
    this.turnPenaltyPerInterval = 2,
  }) : _adventureRepository = adventureRepository;

  final AdventureRepository _adventureRepository;

  /// Identifiants symboliques des lieux considérés comme dépôts sécurisés.
  final Set<String> scoringLocationNames;

  /// Points obtenus lorsqu'un trésor est porté.
  final int treasureFoundPoints;

  /// Bonus obtenu lorsque le trésor est déposé dans un lieu de scoring.
  final int treasureDepositBonus;

  /// Points gagnés par lieu unique visité.
  final int explorationPointPerLocation;

  /// Plafond d'exploration pour éviter les scores explosifs.
  final int explorationCap;

  /// Nombre de tours par tranche de pénalité.
  final int turnPenaltyInterval;

  /// Pénalité appliquée à chaque tranche d'actions.
  final int turnPenaltyPerInterval;

  Set<int>? _cachedScoringLocationIds;
  List<GameObject>? _cachedObjects;

  @override
  Future<ScoreBreakdown> call(Game game) async {
    final List<GameObject> objects = await _ensureObjects();
    final Set<int> scoringLocationIds = await _ensureScoringLocationIds();

    final int treasureScore = _computeTreasureScore(
      game.objectStates,
      objects,
      scoringLocationIds,
    );
    final int explorationScore = _computeExplorationScore(
      game.visitedLocations,
    );
    final int penalties = _computePenalties(game.turns);

    return ScoreBreakdown(
      treasures: treasureScore,
      exploration: explorationScore,
      penalties: penalties,
    );
  }

  Future<List<GameObject>> _ensureObjects() async {
    final cached = _cachedObjects;
    if (cached != null) {
      return cached;
    }
    final objects = await _adventureRepository.getGameObjects();
    _cachedObjects = objects;
    return objects;
  }

  Future<Set<int>> _ensureScoringLocationIds() async {
    final cached = _cachedScoringLocationIds;
    if (cached != null) {
      return cached;
    }
    final List<Location> locations = await _adventureRepository.getLocations();
    final Set<int> ids = <int>{
      for (final Location location in locations)
        if (scoringLocationNames.contains(location.name)) location.id,
    };
    _cachedScoringLocationIds = ids;
    return ids;
  }

  int _computeTreasureScore(
    Map<int, GameObjectState> states,
    List<GameObject> objects,
    Set<int> scoringLocationIds,
  ) {
    if (objects.isEmpty || states.isEmpty) {
      return 0;
    }

    int score = 0;
    for (final GameObject object in objects) {
      if (!object.isTreasure) {
        continue;
      }
      final GameObjectState? state = states[object.id];
      if (state == null) {
        continue;
      }
      if (state.isCarried) {
        score += treasureFoundPoints;
        continue;
      }
      final int? location = state.location ?? state.fixedLocation;
      if (location != null && scoringLocationIds.contains(location)) {
        score += treasureFoundPoints + treasureDepositBonus;
      }
    }
    return score;
  }

  int _computeExplorationScore(Set<int> visitedLocations) {
    if (visitedLocations.isEmpty || explorationPointPerLocation <= 0) {
      return 0;
    }
    final int raw = visitedLocations.length * explorationPointPerLocation;
    if (explorationCap <= 0) {
      return raw;
    }
    return min(raw, explorationCap);
  }

  int _computePenalties(int turns) {
    if (turns <= 0 || turnPenaltyInterval <= 0 || turnPenaltyPerInterval <= 0) {
      return 0;
    }
    final int intervals = turns ~/ turnPenaltyInterval;
    return intervals * turnPenaltyPerInterval;
  }
}
