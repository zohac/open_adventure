import 'package:collection/collection.dart';

/// Value object représentant le détail du score partiel.
class ScoreBreakdown {
  /// Crée un [ScoreBreakdown] agrégant les composantes du score.
  const ScoreBreakdown({
    required this.treasures,
    required this.exploration,
    required this.penalties,
  }) : total = treasures + exploration - penalties;

  /// Points obtenus via les trésors portés ou sécurisés.
  final int treasures;

  /// Points liés à l'exploration de lieux uniques.
  final int exploration;

  /// Pénalités cumulées (tours, autres malus partiels).
  final int penalties;

  /// Total cumulé `trésors + exploration − pénalités`.
  final int total;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScoreBreakdown &&
        treasures == other.treasures &&
        exploration == other.exploration &&
        penalties == other.penalties &&
        total == other.total;
  }

  @override
  int get hashCode => const ListEquality<int>().hash(<int>[
    treasures,
    exploration,
    penalties,
    total,
  ]);

  @override
  String toString() =>
      'ScoreBreakdown(treasures: $treasures, exploration: $exploration, penalties: $penalties, total: $total)';
}
