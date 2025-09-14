import '../../domain/entities/game_object.dart';

class GameObjectModel extends GameObject {
  GameObjectModel({
    required super.id,
    required super.name,
    required super.words,
    super.inventoryDescription,
    required super.locations,
    super.states,
    super.descriptions,
    super.sounds,
    super.changes,
    super.immovable,
    super.isTreasure,
  });

  factory GameObjectModel.fromJson(List<dynamic> json) {
    final name = json[0] as String;
    final Map<String, dynamic> data = json[1] as Map<String, dynamic>;

    final words = List<String>.from(data['words'] ?? []);
    final inventoryDescription = data['inventory'];
    final locationsData = data['locations'];

    // Gérer le fait que 'locations' peut être une chaîne ou une liste
    List<String> locations;
    if (locationsData is String) {
      locations = [locationsData];
    } else if (locationsData is List) {
      locations = List<String>.from(locationsData);
    } else {
      locations = [];
    }

    final states = List<String>.from(data['states'] ?? []);
    final descriptions = List<String>.from(data['descriptions'] ?? []);
    final sounds = List<String>.from(data['sounds'] ?? []);
    final changes = List<String>.from(data['changes'] ?? []);
    final immovable = data['immovable'] ?? false;
    final isTreasure = data['is_treasure'] ?? false;

    return GameObjectModel(
      id: name,
      name: name,
      words: words,
      inventoryDescription: inventoryDescription,
      locations: locations,
      states: states.isNotEmpty ? states : null,
      descriptions: descriptions.isNotEmpty ? descriptions : null,
      sounds: sounds.isNotEmpty ? sounds : null,
      changes: changes.isNotEmpty ? changes : null,
      immovable: immovable,
      isTreasure: isTreasure,
    );
  }

  List<dynamic> toJson() {
    return [
      name,
      {
        'words': words,
        'inventory': inventoryDescription,
        'locations': locations.length == 1 ? locations.first : locations,
        'states': states,
        'descriptions': descriptions,
        'sounds': sounds,
        'changes': changes,
        'immovable': immovable,
        'is_treasure': isTreasure,
      },
    ];
  }

  GameObject toEntity() {
    return GameObject(
      id: name,
      name: name,
      words: words,
      inventoryDescription: inventoryDescription,
      locations: locations,
      states: states!.isNotEmpty ? states : null,
      descriptions: descriptions!.isNotEmpty ? descriptions : null,
      sounds: sounds!.isNotEmpty ? sounds : null,
      changes: changes!.isNotEmpty ? changes : null,
      immovable: immovable,
      isTreasure: isTreasure,
    );
  }

  factory GameObjectModel.fromEntity(GameObject gameObject) {
    return GameObjectModel(
      id: gameObject.name,
      name: gameObject.name,
      words: gameObject.words,
      inventoryDescription: gameObject.inventoryDescription,
      locations: gameObject.locations,
      states: gameObject.states!.isNotEmpty ? gameObject.states : null,
      descriptions: gameObject.descriptions!.isNotEmpty ? gameObject.descriptions : null,
      sounds: gameObject.sounds!.isNotEmpty ? gameObject.sounds : null,
      changes: gameObject.changes!.isNotEmpty ? gameObject.changes : null,
      immovable: gameObject.immovable,
      isTreasure: gameObject.isTreasure,
    );
  }
}
