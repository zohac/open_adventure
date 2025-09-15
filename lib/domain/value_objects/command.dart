/// Command VO — représente une intention utilisateur normalisée.
///
/// Immuable (tous champs `final`), égalité par valeur via `==`.
class Command {
  /// Verbe canonique (ex: 'NORTH', 'TAKE', 'OPEN', 'GOTO').
  final String verb;

  /// Cible optionnelle (ex: id/nom destination ou id objet).
  final String? target;

  /// Crée une commande immuable.
  const Command({required this.verb, this.target});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Command && runtimeType == other.runtimeType && verb == other.verb && target == other.target;

  @override
  int get hashCode => Object.hash(verb, target);

  @override
  String toString() => 'Command(verb: $verb, target: ${target ?? 'null'})';
}
