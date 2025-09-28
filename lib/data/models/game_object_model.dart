import 'package:open_adventure/domain/entities/game_object.dart';

/// Data model for objects.json entries, mapped to [GameObject].
class GameObjectModel extends GameObject {
  /// Inventory label shown in inventory listing (if any).
  final String? inventory;

  /// Optional descriptions per state or single descriptions.
  /// We keep it as a dynamic list to preserve the source structure.
  final List<dynamic>? descriptions;

  /// Optional sounds keys associated to states or usages.
  final List<String>? sounds;

  /// Optional text changes emitted when state changes (same indexing as states).
  final List<String>? changes;

  /// Creates an immutable [GameObjectModel].
  GameObjectModel({
    required super.id,
    required super.name,
    super.words = const [],
    super.locations = const [],
    super.immovable = false,
    super.isTreasure = false,
    this.inventory,
    super.states,
    this.descriptions,
    this.sounds,
    this.changes,
  }) : super(
         stateDescriptions: descriptions == null
             ? null
             : List.unmodifiable(descriptions.whereType<String>().toList()),
         inventoryDescription: inventory,
       );

  /// Constructs a [GameObjectModel] from a flattened JSON map and its [id].
  ///
  /// Expected shape (flattened):
  /// { 'name': String, 'words'?: [String], 'inventory'?: String,
  ///   'locations': String|[String], 'immovable'?: bool, 'is_treasure'?: bool,
  ///   'states'?: [String], 'descriptions'?: [dynamic],
  ///   'sounds'?: [String], 'changes'?: [String] }
  factory GameObjectModel.fromJson(Map<String, dynamic> json, int id) {
    final words = (json['words'] as List?)?.cast<String>() ?? const <String>[];
    final locations = _normalizeLocations(json['locations']);
    final immovable = (json['immovable'] as bool?) ?? false;
    final isTreasure = (json['is_treasure'] as bool?) ?? false;

    List<String>? asStringListOrNull(dynamic v) {
      if (v == null) return null;
      if (v is List && v.isNotEmpty) return v.cast<String>();
      return null;
    }

    List<dynamic>? asDynamicListOrNull(dynamic v) {
      if (v == null) return null;
      if (v is List && v.isNotEmpty) return v.cast<dynamic>();
      return null;
    }

    final states = asStringListOrNull(json['states']);
    final descriptions = asDynamicListOrNull(json['descriptions']);

    return GameObjectModel(
      id: id,
      name: (json['name'] ?? 'Unknown') as String,
      words: words,
      locations: locations,
      immovable: immovable,
      isTreasure: isTreasure,
      inventory: (json['inventory'] as String?)?.trim().isEmpty == true
          ? null
          : (json['inventory'] as String?),
      states: states,
      descriptions: descriptions,
      sounds: asStringListOrNull(json['sounds']),
      changes: asStringListOrNull(json['changes']),
    );
  }

  /// Legacy constructor from raw entry `[name, { ...data }]` (kept for reference).
  factory GameObjectModel.fromEntry(List<dynamic> entry, int id) {
    final name = entry.first as String;
    final data = Map<String, dynamic>.from(entry.last as Map);
    return GameObjectModel.fromJson(<String, dynamic>{
      'name': name,
      ...data,
    }, id);
  }

  /// Converts to domain [GameObject] (subset of fields relevant to Domain).
  GameObject toEntity() => GameObject(
    id: id,
    name: name,
    words: words,
    locations: locations,
    immovable: immovable,
    isTreasure: isTreasure,
    states: states,
    stateDescriptions: stateDescriptions,
    inventoryDescription: inventory,
  );

  /// Serializes back to a flattened JSON map. Normalizes `locations` to a list.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    if (words.isNotEmpty) 'words': words,
    if (inventory != null) 'inventory': inventory,
    'locations': locations,
    if (immovable) 'immovable': true,
    if (isTreasure) 'is_treasure': true,
    if (states != null) 'states': states,
    if (descriptions != null) 'descriptions': descriptions,
    if (sounds != null) 'sounds': sounds,
    if (changes != null) 'changes': changes,
  };

  static List<String> _normalizeLocations(dynamic locationsRaw) {
    if (locationsRaw == null) return const <String>[];
    if (locationsRaw is String) return <String>[locationsRaw];
    if (locationsRaw is List) return locationsRaw.cast<String>();
    return const <String>[];
  }
}
