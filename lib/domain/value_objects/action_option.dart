/// ActionOption — option présentable à l’utilisateur (UI sans logique).
class ActionOption {
  /// Identifiant stable pour déclenchement UI.
  final String id;

  /// Catégorie ('travel', 'interaction', 'meta').
  final String category;

  /// Libellé UI (localisable ultérieurement).
  final String label;

  /// Icône optionnelle (nom Material, par ex.).
  final String? icon;

  /// Verbe canonique utilisé par le moteur.
  final String verb;

  /// Cible optionnelle (destination/objet).
  final String? objectId;

  const ActionOption({
    required this.id,
    required this.category,
    required this.label,
    this.icon,
    required this.verb,
    this.objectId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActionOption &&
          id == other.id &&
          category == other.category &&
          label == other.label &&
          icon == other.icon &&
          verb == other.verb &&
          objectId == other.objectId;

  @override
  int get hashCode => Object.hash(id, category, label, icon, verb, objectId);
}

