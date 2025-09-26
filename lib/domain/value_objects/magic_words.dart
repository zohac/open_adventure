/// MagicWords centralizes the list of incantations used by the adventure.
///
/// These verbs should remain hidden until the player learns them diegetically.
class MagicWords {
  const MagicWords._();

  /// Canonical motion verbs considered "magic words".
  static const Set<String> verbs = {
    'XYZZY',
    'PLUGH',
    'PLOVER',
  };

  /// Returns true when [verb] matches a known incantation (case-insensitive).
  static bool isIncantation(String verb) {
    if (verb.isEmpty) return false;
    return verbs.contains(verb.toUpperCase());
  }
}
