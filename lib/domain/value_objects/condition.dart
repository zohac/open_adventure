/// Enumeration des types de conditions supportés en S3.
enum ConditionType {
  /// Vrai si l'objet est porté.
  carry,

  /// Vrai si l'objet est porté ou présent dans la pièce actuelle.
  withObject,

  /// Négation logique d'une condition imbriquée.
  not,

  /// Vrai si le joueur se situe à un identifiant de lieu donné.
  at,

  /// Vrai si l'état logique de l'objet correspond à la valeur attendue.
  state,

  /// Vrai si la propriété numérique de l'objet correspond à la valeur attendue.
  prop,

  /// Vrai si un indicateur global (flag) est activé.
  have,
}

/// Condition métier évaluée par [EvaluateCondition].
class Condition {
  /// Type de condition.
  final ConditionType type;

  /// Identifiant objet concerné (si applicable).
  final int? objectId;

  /// Identifiant de lieu ciblé (pour [ConditionType.at]).
  final int? locationId;

  /// Valeur attendue (état/prop) pour comparaison stricte.
  final Object? value;

  /// Nom du flag global (pour [ConditionType.have]).
  final String? flagKey;

  /// Condition imbriquée (pour [ConditionType.not]).
  final Condition? inner;

  /// Crée une condition immuable.
  const Condition._({
    required this.type,
    this.objectId,
    this.locationId,
    this.value,
    this.flagKey,
    this.inner,
  });

  /// Condition « porter l'objet ».
  const Condition.carry({required int objectId})
    : this._(type: ConditionType.carry, objectId: objectId);

  /// Condition « avec l'objet ».
  const Condition.withObject({required int objectId})
    : this._(type: ConditionType.withObject, objectId: objectId);

  /// Condition « joueur à un lieu précis ».
  const Condition.at({required int locationId})
    : this._(type: ConditionType.at, locationId: locationId);

  /// Condition « état de l'objet ».
  const Condition.state({required int objectId, required Object? value})
    : this._(type: ConditionType.state, objectId: objectId, value: value);

  /// Condition « propriété numérique de l'objet ».
  const Condition.prop({required int objectId, required Object? value})
    : this._(type: ConditionType.prop, objectId: objectId, value: value);

  /// Condition « flag global possédé ».
  const Condition.have({required String flagKey})
    : this._(type: ConditionType.have, flagKey: flagKey);

  /// Condition négative : inverse le résultat d'une autre condition.
  const Condition.not([Condition? inner])
    : this._(type: ConditionType.not, inner: inner);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Condition &&
        type == other.type &&
        objectId == other.objectId &&
        locationId == other.locationId &&
        value == other.value &&
        flagKey == other.flagKey &&
        inner == other.inner;
  }

  @override
  int get hashCode =>
      Object.hash(type, objectId, locationId, value, flagKey, inner);
}
