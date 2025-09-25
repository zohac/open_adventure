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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <
      LocalizationsDelegate<dynamic>>[
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

  String _string(String key) {
    final table = _localizedValues[locale.languageCode] ??
        _localizedValues[supportedLocales.first.languageCode]!;
    return table[key] ?? (throw ArgumentError('Missing "$key" for locale'));
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
    'homeMenuOptionsSubtitle':
        "Configurer l'expérience audio et tactile.",
    'homeMenuCreditsLabel': 'Crédits',
    'homeMenuCreditsSubtitle': "L'équipe derrière cette aventure.",
  },
};
