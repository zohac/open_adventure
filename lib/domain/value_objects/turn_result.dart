import 'package:open_adventure/domain/entities/game.dart';

/// TurnResult VO — résultat d'un tour: nouvel état + messages pour l'UI.
///
/// Immuable; égalité par valeur via `==`.
class TurnResult {
  /// Nouvel état de jeu après application de la commande.
  final Game newGame;

  /// Messages (journal) à afficher côté UI.
  final List<String> messages;

  /// Crée un résultat immuable; la liste est copiée pour garantir l'immuabilité.
  TurnResult(this.newGame, List<String> messages) : messages = List.unmodifiable(messages);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TurnResult && runtimeType == other.runtimeType && newGame == other.newGame && _listEquals(messages, other.messages);

  @override
  int get hashCode => Object.hash(newGame, Object.hashAll(messages));
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

