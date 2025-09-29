import 'package:collection/collection.dart';
import 'package:open_adventure/domain/entities/game.dart';

/// Result of executing a dwarf system tick.
class DwarfTickResult {
  /// Updated game state after resolving dwarf logic.
  final Game game;

  /// Journal messages generated during the tick.
  final List<String> messages;

  /// Creates an immutable [DwarfTickResult].
  DwarfTickResult({
    required this.game,
    List<String> messages = const <String>[],
  }) : messages = List<String>.unmodifiable(messages);

  static const ListEquality<String> _listEquality = ListEquality<String>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DwarfTickResult &&
        game == other.game &&
        _listEquality.equals(messages, other.messages);
  }

  @override
  int get hashCode => Object.hash(game, _listEquality.hash(messages));
}
