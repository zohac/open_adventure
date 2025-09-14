import 'package:open_adventure/domain/entities/game_object.dart';

/// Data model for objects.json entries, mapped to [GameObject].
class GameObjectModel extends GameObject {
  /// Constructs a [GameObjectModel] from the JSON entry and its sequential [id].
  ///
  /// The JSON shape in assets/data/objects.json is `[name, { ...data }]`.
  factory GameObjectModel.fromEntry(List<dynamic> entry, int id) {
    final name = entry.first as String;
    final data = Map<String, dynamic>.from(entry.last as Map);
    final words = (data['words'] as List?)?.cast<String>() ?? const <String>[];
    final locationsRaw = data['locations'];
    final List<String> locations;
    if (locationsRaw == null) {
      locations = const <String>[];
    } else if (locationsRaw is String) {
      locations = <String>[locationsRaw];
    } else if (locationsRaw is List) {
      locations = locationsRaw.cast<String>();
    } else {
      locations = const <String>[];
    }
    final immovable = (data['immovable'] as bool?) ?? false;
    final isTreasure = (data['is_treasure'] as bool?) ?? false;
    return GameObjectModel(
      id: id,
      name: name,
      words: words,
      locations: locations,
      immovable: immovable,
      isTreasure: isTreasure,
    );
  }

  /// Creates an immutable [GameObjectModel].
  const GameObjectModel({
    required super.id,
    required super.name,
    super.words = const [],
    super.locations = const [],
    super.immovable = false,
    super.isTreasure = false,
  });
}

