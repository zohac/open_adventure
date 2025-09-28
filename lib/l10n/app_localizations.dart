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
    if (rawLabel.startsWith('actions.interaction.')) {
      final segments = rawLabel.split('.');
      if (segments.length >= 4) {
        final verb = segments[2];
        final objectKey = segments.sublist(3).join('.');
        final templateKey = 'actions.interaction.$verb';
        final template = _maybeString(templateKey);
        final objectLabel = _resolveObjectLabel(objectKey);
        if (template != null) {
          return template.replaceAll('{object}', objectLabel);
        }
        final capitalizedVerb = verb.isEmpty
            ? verb
            : '${verb[0].toUpperCase()}${verb.substring(1).toLowerCase()}';
        return '$capitalizedVerb $objectLabel';
      }
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

  String _resolveObjectLabel(String objectKey) {
    final localizationKey = 'objects.$objectKey.label';
    final localized = _maybeString(localizationKey);
    if (localized != null) {
      return localized;
    }
    final beautified = objectKey
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
    return beautified.isEmpty ? objectKey : beautified;
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

const Map<String, Map<String, String>> _localizedValues = <String, Map<String, String>>{
  'en': {
    'actions.interaction.close': 'Close {object}',
    'actions.interaction.drop': 'Drop {object}',
    'actions.interaction.examine': 'Examine {object}',
    'actions.interaction.extinguish': 'Extinguish {object}',
    'actions.interaction.light': 'Light {object}',
    'actions.interaction.open': 'Open {object}',
    'actions.interaction.take': 'Take {object}',
    'actions.inventory.label': 'Inventory',
    'actions.map.label': 'Map',
    'actions.observer.label': 'Observe',
    'actions.travel.back': 'Go back',
    'adventureActionMotionFallback': 'Go to {destination}',
    'adventureActionMotionMagicWord': 'Speak {word}',
    'adventureActionMotionUnknown': 'Explore the area',
    'adventureActionsEmptyState': 'No actions available',
    'adventureActionsMoreButtonLabel': 'More…',
    'adventureActionsMoreSheetTitle': 'Additional actions',
    'adventureActionsSectionTitle': 'Actions',
    'adventureActionsTravelMissingHint': 'No immediate exits. Observe your surroundings.',
    'adventureAudioSettingsTooltip': 'Audio settings',
    'adventureDescriptionEmptyPlaceholder': '...',
    'adventureDescriptionSectionTitle': 'Description',
    'adventureJournalEmptyState': 'No events yet',
    'adventureJournalSectionTitle': 'Journal',
    'adventureLocationImageSemanticsFallback': 'Location illustration',
    'appTitle': 'Open Adventure',
    'homeHeroSubtitle': 'Embark on the cult text expedition, remastered for mobile.',
    'homeHeroTitle': 'Open Adventure',
    'homeMenuContinueLabel': 'Continue',
    'homeMenuContinueSubtitle': 'Last turn: {turns}, location #{location}',
    'homeMenuCreditsLabel': 'Credits',
    'homeMenuCreditsSubtitle': 'Meet the team behind this adventure.',
    'homeMenuLoadLabel': 'Load',
    'homeMenuLoadSubtitle': 'Open manual save slots.',
    'homeMenuNewGameLabel': 'New game',
    'homeMenuNewGameSubtitle': 'Begin exploring the colossal cavern.',
    'homeMenuOptionsLabel': 'Options',
    'homeMenuOptionsSubtitle': 'Configure audio and tactile feedback.',
    'motion.back.label': 'Retrace steps',
    'motion.bedquilt.label': 'Go to Bedquilt',
    'motion.cave.label': 'Go to the cave',
    'motion.cavern.label': 'Go to the cavern',
    'motion.crawl.label': 'Crawl forward',
    'motion.cross.label': 'Cross over',
    'motion.depression.label': 'Go to the depression',
    'motion.down.label': 'Climb down',
    'motion.east.label': 'Go east',
    'motion.enter.label': 'Enter',
    'motion.entrance.label': 'Go to the entrance',
    'motion.forward.label': 'Go forward',
    'motion.left.label': 'Go left',
    'motion.look.label': 'Look around',
    'motion.ne.label': 'Go north-east',
    'motion.north.label': 'Go north',
    'motion.nw.label': 'Go north-west',
    'motion.office.label': 'Go to the office',
    'motion.oriental.label': 'Go to the Oriental room',
    'motion.out.label': 'Exit',
    'motion.plover.label': 'Speak PLOVER',
    'motion.plugh.label': 'Speak PLUGH',
    'motion.reservoir.label': 'Go to the reservoir',
    'motion.right.label': 'Go right',
    'motion.se.label': 'Go south-east',
    'motion.shellroom.label': 'Go to the shell room',
    'motion.south.label': 'Go south',
    'motion.stream.label': 'Follow the stream',
    'motion.sw.label': 'Go south-west',
    'motion.unknown.label': 'Explore the area',
    'motion.up.label': 'Climb up',
    'motion.west.label': 'Go west',
    'motion.xyzzy.label': 'Speak XYZZY',
    'objects.AMBER.label': 'Amber gemstone',
    'objects.AXE.label': 'Dwarf\'s axe',
    'objects.BATTERY.label': 'Batteries',
    'objects.BEAR.label': 'There is a ferocious cave bear eyeing you from the far end of the room!',
    'objects.BIRD.label': 'Little bird in cage',
    'objects.BLOOD.label': 'blood',
    'objects.BOTTLE.label': 'Small bottle',
    'objects.CAGE.label': 'Wicker cage',
    'objects.CAVITY.label': 'cavity',
    'objects.CHAIN.label': 'Golden chain',
    'objects.CHASM.label': 'chasm',
    'objects.CHEST.label': 'Treasure chest',
    'objects.CLAM.label': 'Giant clam >GRUNT!<',
    'objects.COINS.label': 'Rare coins',
    'objects.DOOR.label': 'rusty door',
    'objects.DRAGON.label': 'dragon',
    'objects.DWARF.label': 'Dwarf',
    'objects.EGGS.label': 'Golden eggs',
    'objects.EMERALD.label': 'Egg-sized emerald',
    'objects.FISSURE.label': 'fissure',
    'objects.FOOD.label': 'Tasty food',
    'objects.GRATE.label': 'grate',
    'objects.JADE.label': 'Jade necklace',
    'objects.KEYS.label': 'Set of keys',
    'objects.KNIFE.label': 'Knife',
    'objects.LAMP.label': 'Brass lantern',
    'objects.MAGAZINE.label': 'Spelunker Today',
    'objects.MESSAG.label': 'message in second maze',
    'objects.MIRROR.label': 'mirror',
    'objects.NUGGET.label': 'Large gold nugget',
    'objects.OBJ_13.label': 'stone tablet',
    'objects.OBJ_26.label': 'stalactite',
    'objects.OBJ_27.label': 'shadowy figure and/or window',
    'objects.OBJ_29.label': 'cave drawings',
    'objects.OBJ_30.label': 'pirate/genie',
    'objects.OBJ_40.label': 'carpet and/or moss and/or curtains',
    'objects.OBJ_47.label': 'mud',
    'objects.OBJ_48.label': 'note',
    'objects.OBJ_51.label': 'Several diamonds',
    'objects.OBJ_52.label': 'Bars of silver',
    'objects.OBJ_53.label': 'Precious jewelry',
    'objects.OBJ_63.label': 'Rare spices',
    'objects.OBJ_69.label': 'Ebony statuette',
    'objects.OGRE.label': 'ogre',
    'objects.OIL.label': 'Oil in the bottle',
    'objects.OYSTER.label': 'Giant oyster >GROAN!<',
    'objects.PEARL.label': 'Glistening pearl',
    'objects.PILLOW.label': 'Velvet pillow',
    'objects.PLANT.label': 'plant',
    'objects.PLANT2.label': 'phony plant',
    'objects.PYRAMID.label': 'Platinum pyramid',
    'objects.RABBITFOOT.label': 'Leporine appendage',
    'objects.RESER.label': 'reservoir',
    'objects.ROD.label': 'Black rod',
    'objects.ROD2.label': 'Black rod',
    'objects.RUBY.label': 'Giant ruby',
    'objects.RUG.label': 'Persian rug',
    'objects.SAPPH.label': 'Star sapphire',
    'objects.SIGN.label': 'sign',
    'objects.SNAKE.label': 'snake',
    'objects.STEPS.label': 'steps',
    'objects.TRIDENT.label': 'Jeweled trident',
    'objects.TROLL.label': 'troll',
    'objects.TROLL2.label': 'phony troll',
    'objects.URN.label': 'urn',
    'objects.VASE.label': 'Ming vase',
    'objects.VEND.label': 'vending machine',
    'objects.VOLCANO.label': 'volcano and/or geyser',
    'objects.WATER.label': 'Water in the bottle',
  },
  'fr': {
    'actions.interaction.close': 'Fermer {object}',
    'actions.interaction.drop': 'Déposer {object}',
    'actions.interaction.examine': 'Examiner {object}',
    'actions.interaction.extinguish': 'Éteindre {object}',
    'actions.interaction.light': 'Allumer {object}',
    'actions.interaction.open': 'Ouvrir {object}',
    'actions.interaction.take': 'Prendre {object}',
    'actions.inventory.label': 'Inventaire',
    'actions.map.label': 'Carte',
    'actions.observer.label': 'Observer',
    'actions.travel.back': 'Revenir',
    'adventureActionMotionFallback': 'Se rendre à {destination}',
    'adventureActionMotionMagicWord': 'Prononcer {word}',
    'adventureActionMotionUnknown': 'Explorer les environs',
    'adventureActionsEmptyState': 'Aucune action disponible',
    'adventureActionsMoreButtonLabel': 'Plus…',
    'adventureActionsMoreSheetTitle': 'Actions supplémentaires',
    'adventureActionsSectionTitle': 'Actions',
    'adventureActionsTravelMissingHint': 'Aucune sortie immédiate. Observez les alentours.',
    'adventureAudioSettingsTooltip': 'Réglages audio',
    'adventureDescriptionEmptyPlaceholder': '...',
    'adventureDescriptionSectionTitle': 'Description',
    'adventureJournalEmptyState': 'Aucun événement pour le moment',
    'adventureJournalSectionTitle': 'Journal',
    'adventureLocationImageSemanticsFallback': 'Illustration du lieu',
    'appTitle': 'Open Adventure',
    'homeHeroSubtitle': 'Partez pour l\'expédition textuelle culte, remasterisée pour mobile.',
    'homeHeroTitle': 'Open Adventure',
    'homeMenuContinueLabel': 'Continuer',
    'homeMenuContinueSubtitle': 'Dernier tour : {turns}, lieu #{location}',
    'homeMenuCreditsLabel': 'Crédits',
    'homeMenuCreditsSubtitle': 'L\'équipe derrière cette aventure.',
    'homeMenuLoadLabel': 'Charger',
    'homeMenuLoadSubtitle': 'Accéder aux sauvegardes manuelles.',
    'homeMenuNewGameLabel': 'Nouvelle partie',
    'homeMenuNewGameSubtitle': 'Commencer l\'exploration de la caverne.',
    'homeMenuOptionsLabel': 'Options',
    'homeMenuOptionsSubtitle': 'Configurer l\'expérience audio et tactile.',
    'motion.back.label': 'Revenir sur ses pas',
    'motion.bedquilt.label': 'Aller vers Bedquilt',
    'motion.cave.label': 'Aller vers la grotte',
    'motion.cavern.label': 'Aller vers la caverne',
    'motion.crawl.label': 'Ramper',
    'motion.cross.label': 'Traverser',
    'motion.depression.label': 'Aller vers la dépression',
    'motion.down.label': 'Descendre',
    'motion.east.label': 'Aller Est',
    'motion.enter.label': 'Entrer',
    'motion.entrance.label': 'Aller vers l’entrée',
    'motion.forward.label': 'Avancer',
    'motion.left.label': 'Aller à gauche',
    'motion.look.label': 'Observer les alentours',
    'motion.ne.label': 'Aller Nord-Est',
    'motion.north.label': 'Aller Nord',
    'motion.nw.label': 'Aller Nord-Ouest',
    'motion.office.label': 'Aller vers le bureau',
    'motion.oriental.label': 'Aller vers la salle orientale',
    'motion.out.label': 'Sortir',
    'motion.plover.label': 'Prononcer PLOVER',
    'motion.plugh.label': 'Prononcer PLUGH',
    'motion.reservoir.label': 'Aller vers le réservoir',
    'motion.right.label': 'Aller à droite',
    'motion.se.label': 'Aller Sud-Est',
    'motion.shellroom.label': 'Aller vers la salle des coquillages',
    'motion.south.label': 'Aller Sud',
    'motion.stream.label': 'Suivre le courant',
    'motion.sw.label': 'Aller Sud-Ouest',
    'motion.unknown.label': 'Explorer les environs',
    'motion.up.label': 'Monter',
    'motion.west.label': 'Aller Ouest',
    'motion.xyzzy.label': 'Prononcer XYZZY',
    'objects.AMBER.label': 'Amber gemstone',
    'objects.AXE.label': 'Dwarf\'s axe',
    'objects.BATTERY.label': 'Batteries',
    'objects.BEAR.label': 'There is a ferocious cave bear eyeing you from the far end of the room!',
    'objects.BIRD.label': 'Little bird in cage',
    'objects.BLOOD.label': 'blood',
    'objects.BOTTLE.label': 'Small bottle',
    'objects.CAGE.label': 'Wicker cage',
    'objects.CAVITY.label': 'cavity',
    'objects.CHAIN.label': 'Golden chain',
    'objects.CHASM.label': 'chasm',
    'objects.CHEST.label': 'Treasure chest',
    'objects.CLAM.label': 'Giant clam >GRUNT!<',
    'objects.COINS.label': 'Rare coins',
    'objects.DOOR.label': 'rusty door',
    'objects.DRAGON.label': 'dragon',
    'objects.DWARF.label': 'Dwarf',
    'objects.EGGS.label': 'Golden eggs',
    'objects.EMERALD.label': 'Egg-sized emerald',
    'objects.FISSURE.label': 'fissure',
    'objects.FOOD.label': 'Tasty food',
    'objects.GRATE.label': 'grate',
    'objects.JADE.label': 'Jade necklace',
    'objects.KEYS.label': 'Set of keys',
    'objects.KNIFE.label': 'Knife',
    'objects.LAMP.label': 'Brass lantern',
    'objects.MAGAZINE.label': 'Spelunker Today',
    'objects.MESSAG.label': 'message in second maze',
    'objects.MIRROR.label': 'mirror',
    'objects.NUGGET.label': 'Large gold nugget',
    'objects.OBJ_13.label': 'stone tablet',
    'objects.OBJ_26.label': 'stalactite',
    'objects.OBJ_27.label': 'shadowy figure and/or window',
    'objects.OBJ_29.label': 'cave drawings',
    'objects.OBJ_30.label': 'pirate/genie',
    'objects.OBJ_40.label': 'carpet and/or moss and/or curtains',
    'objects.OBJ_47.label': 'mud',
    'objects.OBJ_48.label': 'note',
    'objects.OBJ_51.label': 'Several diamonds',
    'objects.OBJ_52.label': 'Bars of silver',
    'objects.OBJ_53.label': 'Precious jewelry',
    'objects.OBJ_63.label': 'Rare spices',
    'objects.OBJ_69.label': 'Ebony statuette',
    'objects.OGRE.label': 'ogre',
    'objects.OIL.label': 'Oil in the bottle',
    'objects.OYSTER.label': 'Giant oyster >GROAN!<',
    'objects.PEARL.label': 'Glistening pearl',
    'objects.PILLOW.label': 'Velvet pillow',
    'objects.PLANT.label': 'plant',
    'objects.PLANT2.label': 'phony plant',
    'objects.PYRAMID.label': 'Platinum pyramid',
    'objects.RABBITFOOT.label': 'Leporine appendage',
    'objects.RESER.label': 'reservoir',
    'objects.ROD.label': 'Black rod',
    'objects.ROD2.label': 'Black rod',
    'objects.RUBY.label': 'Giant ruby',
    'objects.RUG.label': 'Persian rug',
    'objects.SAPPH.label': 'Star sapphire',
    'objects.SIGN.label': 'sign',
    'objects.SNAKE.label': 'snake',
    'objects.STEPS.label': 'steps',
    'objects.TRIDENT.label': 'Jeweled trident',
    'objects.TROLL.label': 'troll',
    'objects.TROLL2.label': 'phony troll',
    'objects.URN.label': 'urn',
    'objects.VASE.label': 'Ming vase',
    'objects.VEND.label': 'vending machine',
    'objects.VOLCANO.label': 'volcano and/or geyser',
    'objects.WATER.label': 'Water in the bottle',
  },
};
