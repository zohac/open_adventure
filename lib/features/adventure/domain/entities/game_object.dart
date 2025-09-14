class GameObject {
  final String id;
  final String name;
  final List<String> words; // Mots clés associés à l'objet
  final String? inventoryDescription; // Description de l'objet dans l'inventaire
  final List<String> locations; // Liste des emplacements initiaux de l'objet
  final List<String>? states; // États possibles de l'objet
  final List<String>? descriptions; // Descriptions selon l'état
  final List<String>? sounds; // Sons associés à l'objet
  final List<String>? changes; // Messages de changement d'état
  final bool immovable; // Indique si l'objet est immobile
  final bool isTreasure; // Indique si c'est un trésor

  GameObject({
    required this.id,
    required this.name,
    required this.words,
    this.inventoryDescription,
    required this.locations,
    this.states,
    this.descriptions,
    this.sounds,
    this.changes,
    this.immovable = false,
    this.isTreasure = false,
  });
}
