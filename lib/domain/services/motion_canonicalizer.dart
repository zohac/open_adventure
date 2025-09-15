/// MotionCanonicalizer — normalise les mouvements vers une forme canonique
/// et expose des métadonnées UI (clé de label, icône, priorité de tri).
abstract class MotionCanonicalizer {
  /// Retourne la forme canonique d’un mouvement brut (ex: 'W', 'WEST', 'MOT_2' → 'WEST').
  String toCanonical(String raw);

  /// Clé UI (pour ARB/i18n) associée au mouvement canonique.
  String uiKey(String canonical);

  /// Nom d’icône Material recommandé pour ce mouvement.
  String iconName(String canonical);

  /// Priorité de tri (0 = cardinal, 1 = vertical (in/out/up/down), 2 = autres).
  int priority(String canonical);
}

