import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Provides localized strings for the application without relying on the
/// Flutter toolchain generated output, enabling analyzer execution in CI.
class AppLocalizations {
  /// Creates a localization bundle bound to the provided [locale].
  const AppLocalizations(this.locale);

  /// Active locale for the current bundle.
  final Locale locale;

  /// Looks up the nearest [AppLocalizations] instance in the widget tree.
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  /// Localizations delegates required to wire the bundle in a [MaterialApp].
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// Supported locales exposed to the Flutter framework.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Delegate responsible for loading [AppLocalizations] instances.
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Application title shown by the operating system.
  String get appTitle => _string('appTitle');

  /// Hero title displayed on the home screen banner.
  String get homeHeroTitle => _string('homeHeroTitle');

  /// Hero subtitle displayed on the home screen banner.
  String get homeHeroSubtitle => _string('homeHeroSubtitle');

  /// Label of the "new game" menu entry.
  String get homeMenuNewGameLabel => _string('homeMenuNewGameLabel');

  /// Subtitle of the "new game" menu entry.
  String get homeMenuNewGameSubtitle => _string('homeMenuNewGameSubtitle');

  /// Label of the "continue" menu entry.
  String get homeMenuContinueLabel => _string('homeMenuContinueLabel');

  /// Subtitle for the "continue" menu entry, formatted with save metadata.
  String homeMenuContinueSubtitle({required int turns, required int location}) {
    return _string('homeMenuContinueSubtitle')
        .replaceAll('{turns}', '$turns')
        .replaceAll('{location}', '$location');
  }

  /// Label of the "load" menu entry.
  String get homeMenuLoadLabel => _string('homeMenuLoadLabel');

  /// Subtitle of the "load" menu entry.
  String get homeMenuLoadSubtitle => _string('homeMenuLoadSubtitle');

  /// Label of the "options" menu entry.
  String get homeMenuOptionsLabel => _string('homeMenuOptionsLabel');

  /// Subtitle of the "options" menu entry.
  String get homeMenuOptionsSubtitle => _string('homeMenuOptionsSubtitle');

  /// Label of the "credits" menu entry.
  String get homeMenuCreditsLabel => _string('homeMenuCreditsLabel');

  /// Subtitle of the "credits" menu entry.
  String get homeMenuCreditsSubtitle => _string('homeMenuCreditsSubtitle');

  /// Tooltip shown on the adventure app bar to reach audio settings.
  String get adventureAudioSettingsTooltip =>
      _string('adventureAudioSettingsTooltip');

  /// Heading displayed above the location description.
  String get adventureDescriptionSectionTitle =>
      _string('adventureDescriptionSectionTitle');

  /// Placeholder rendered when the current location has no description.
  String get adventureDescriptionEmptyPlaceholder =>
      _string('adventureDescriptionEmptyPlaceholder');

  /// Heading displayed above the list of available actions.
  String get adventureActionsSectionTitle =>
      _string('adventureActionsSectionTitle');

  /// Hint displayed when no travel actions are present in the primary list.
  String get adventureActionsTravelMissingHint =>
      _string('adventureActionsTravelMissingHint');

  /// Placeholder rendered when no actions at all are available.
  String get adventureActionsEmptyState =>
      _string('adventureActionsEmptyState');

  /// Label displayed on the overflow button exposing additional actions.
  String get adventureActionsMoreButtonLabel =>
      _string('adventureActionsMoreButtonLabel');

  /// Title rendered at the top of the overflow bottom sheet.
  String get adventureActionsMoreSheetTitle =>
      _string('adventureActionsMoreSheetTitle');

  /// Heading displayed above the journal entries.
  String get adventureJournalSectionTitle =>
      _string('adventureJournalSectionTitle');

  /// Placeholder rendered when no journal entry is available yet.
  String get adventureJournalEmptyState =>
      _string('adventureJournalEmptyState');

  /// Semantics label used for the location illustration fallback.
  String get adventureLocationImageSemanticsFallback =>
      _string('adventureLocationImageSemanticsFallback');

  /// Returns a localized label for the provided action [rawLabel] key.
  String resolveActionLabel(String rawLabel) {
    final direct = _maybeString(rawLabel);
    if (direct != null) {
      return direct;
    }
    const magicWords = {'XYZZY', 'PLUGH', 'PLOVER'};
    if (rawLabel.startsWith('motion.') && rawLabel.endsWith('.label')) {
      final slug = rawLabel.substring(7, rawLabel.length - 6);
      final canonical = slug.toUpperCase();
      final canonicalKey = 'motion.${canonical.toLowerCase()}.label';
      final override = _maybeString(canonicalKey);
      if (override != null) {
        return override;
      }
      if (magicWords.contains(canonical)) {
        return _string('adventureActionMotionMagicWord')
            .replaceAll('{word}', canonical);
      }
      if (canonical == 'UNKNOWN') {
        return _string('adventureActionMotionUnknown');
      }
      final beautified = canonical
          .toLowerCase()
          .replaceAll('_', ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .map(
            (part) =>
                '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
          )
          .join(' ');
      return _string('adventureActionMotionFallback')
          .replaceAll('{destination}', beautified);
    }
    return rawLabel;
  }

  String _string(String key) {
    final value = _maybeString(key);
    if (value != null) {
      return value;
    }
    throw ArgumentError('Missing "$key" for locale');
  }

  String? _maybeString(String key) {
    final table = _localizedValues[locale.languageCode] ??
        _localizedValues[supportedLocales.first.languageCode]!;
    return table[key];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const Map<String, Map<String, String>> _localizedValues =
    <String, Map<String, String>>{
  'en': <String, String>{
    'appTitle': 'Open Adventure',
    'homeHeroTitle': 'Open Adventure',
    'homeHeroSubtitle':
        'Embark on the cult text expedition, remastered for mobile.',
    'homeMenuNewGameLabel': 'New game',
    'homeMenuNewGameSubtitle': 'Begin exploring the colossal cavern.',
    'homeMenuContinueLabel': 'Continue',
    'homeMenuContinueSubtitle': 'Last turn: {turns}, location #{location}',
    'homeMenuLoadLabel': 'Load',
    'homeMenuLoadSubtitle': 'Open manual save slots.',
    'homeMenuOptionsLabel': 'Options',
    'homeMenuOptionsSubtitle': 'Configure audio and tactile feedback.',
    'homeMenuCreditsLabel': 'Credits',
    'homeMenuCreditsSubtitle': 'Meet the team behind this adventure.',
    'adventureAudioSettingsTooltip': 'Audio settings',
    'adventureDescriptionSectionTitle': 'Description',
    'adventureDescriptionEmptyPlaceholder': '...',
    'adventureActionsSectionTitle': 'Actions',
    'adventureActionsTravelMissingHint':
        'No immediate exits. Observe your surroundings.',
    'adventureActionsEmptyState': 'No actions available',
    'adventureActionsMoreButtonLabel': 'More…',
    'adventureActionsMoreSheetTitle': 'Additional actions',
    'adventureJournalSectionTitle': 'Journal',
    'adventureJournalEmptyState': 'No events yet',
    'adventureLocationImageSemanticsFallback': 'Location illustration',
    'adventureActionMotionMagicWord': 'Speak {word}',
    'adventureActionMotionUnknown': 'Explore the area',
    'adventureActionMotionFallback': 'Go to {destination}',
    'actions.travel.back': 'Go back',
    'actions.observer.label': 'Observe',
    'motion.north.label': 'Go north',
    'motion.south.label': 'Go south',
    'motion.east.label': 'Go east',
    'motion.west.label': 'Go west',
    'motion.up.label': 'Climb up',
    'motion.down.label': 'Climb down',
    'motion.enter.label': 'Enter',
    'motion.out.label': 'Exit',
    'motion.forward.label': 'Go forward',
    'motion.back.label': 'Retrace steps',
    'motion.ne.label': 'Go north-east',
    'motion.se.label': 'Go south-east',
    'motion.sw.label': 'Go south-west',
    'motion.nw.label': 'Go north-west',
    'motion.left.label': 'Go left',
    'motion.right.label': 'Go right',
    'motion.look.label': 'Look around',
    'motion.cave.label': 'Go to the cave',
    'motion.cavern.label': 'Go to the cavern',
    'motion.crawl.label': 'Crawl forward',
    'motion.cross.label': 'Cross over',
    'motion.depression.label': 'Go to the depression',
    'motion.entrance.label': 'Go to the entrance',
    'motion.bedquilt.label': 'Go to Bedquilt',
    'motion.office.label': 'Go to the office',
    'motion.oriental.label': 'Go to the Oriental room',
    'motion.reservoir.label': 'Go to the reservoir',
    'motion.shellroom.label': 'Go to the shell room',
    'motion.stream.label': 'Follow the stream',
    'motion.plover.label': 'Speak PLOVER',
    'motion.plugh.label': 'Speak PLUGH',
    'motion.xyzzy.label': 'Speak XYZZY',
    'motion.unknown.label': 'Explore the area',
  },
  'fr': <String, String>{
    'appTitle': 'Open Adventure',
    'homeHeroTitle': 'Open Adventure',
    'homeHeroSubtitle':
        "Partez pour l'expédition textuelle culte, remasterisée pour mobile.",
    'homeMenuNewGameLabel': 'Nouvelle partie',
    'homeMenuNewGameSubtitle': "Commencer l'exploration de la caverne.",
    'homeMenuContinueLabel': 'Continuer',
    'homeMenuContinueSubtitle': 'Dernier tour : {turns}, lieu #{location}',
    'homeMenuLoadLabel': 'Charger',
    'homeMenuLoadSubtitle': 'Accéder aux sauvegardes manuelles.',
    'homeMenuOptionsLabel': 'Options',
    'homeMenuOptionsSubtitle': "Configurer l'expérience audio et tactile.",
    'homeMenuCreditsLabel': 'Crédits',
    'homeMenuCreditsSubtitle': "L'équipe derrière cette aventure.",
    'adventureAudioSettingsTooltip': 'Réglages audio',
    'adventureDescriptionSectionTitle': 'Description',
    'adventureDescriptionEmptyPlaceholder': '...',
    'adventureActionsSectionTitle': 'Actions',
    'adventureActionsTravelMissingHint':
        'Aucune sortie immédiate. Observez les alentours.',
    'adventureActionsEmptyState': 'Aucune action disponible',
    'adventureActionsMoreButtonLabel': 'Plus…',
    'adventureActionsMoreSheetTitle': 'Actions supplémentaires',
    'adventureJournalSectionTitle': 'Journal',
    'adventureJournalEmptyState': 'Aucun événement pour le moment',
    'adventureLocationImageSemanticsFallback': 'Illustration du lieu',
    'adventureActionMotionMagicWord': 'Prononcer {word}',
    'adventureActionMotionUnknown': 'Explorer les environs',
    'adventureActionMotionFallback': 'Se rendre à {destination}',
    'actions.travel.back': 'Revenir',
    'actions.observer.label': 'Observer',
    'motion.north.label': 'Aller Nord',
    'motion.south.label': 'Aller Sud',
    'motion.east.label': 'Aller Est',
    'motion.west.label': 'Aller Ouest',
    'motion.up.label': 'Monter',
    'motion.down.label': 'Descendre',
    'motion.enter.label': 'Entrer',
    'motion.out.label': 'Sortir',
    'motion.forward.label': 'Avancer',
    'motion.back.label': 'Revenir sur ses pas',
    'motion.ne.label': 'Aller Nord-Est',
    'motion.se.label': 'Aller Sud-Est',
    'motion.sw.label': 'Aller Sud-Ouest',
    'motion.nw.label': 'Aller Nord-Ouest',
    'motion.left.label': 'Aller à gauche',
    'motion.right.label': 'Aller à droite',
    'motion.look.label': 'Observer les alentours',
    'motion.cave.label': 'Aller vers la grotte',
    'motion.cavern.label': 'Aller vers la caverne',
    'motion.crawl.label': 'Ramper',
    'motion.cross.label': 'Traverser',
    'motion.depression.label': 'Aller vers la dépression',
    'motion.entrance.label': 'Aller vers l’entrée',
    'motion.bedquilt.label': 'Aller vers Bedquilt',
    'motion.office.label': 'Aller vers le bureau',
    'motion.oriental.label': 'Aller vers la salle orientale',
    'motion.reservoir.label': 'Aller vers le réservoir',
    'motion.shellroom.label': 'Aller vers la salle des coquillages',
    'motion.stream.label': 'Suivre le courant',
    'motion.plover.label': 'Prononcer PLOVER',
    'motion.plugh.label': 'Prononcer PLUGH',
    'motion.xyzzy.label': 'Prononcer XYZZY',
    'motion.unknown.label': 'Explorer les environs',
  },
};
