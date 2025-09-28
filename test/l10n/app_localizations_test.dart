import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations.resolveActionLabel', () {
    const en = AppLocalizations(Locale('en'));
    const fr = AppLocalizations(Locale('fr'));

    test('resolves direct interaction labels with localized object name', () {
      expect(
        en.resolveActionLabel('actions.interaction.examine.LAMP'),
        'Examine Brass lantern',
      );
      expect(
        fr.resolveActionLabel('actions.interaction.take.KEYS'),
        'Prendre Set of keys',
      );
    });

    test('falls back to beautified identifier when object label is missing', () {
      expect(
        en.resolveActionLabel('actions.interaction.drop.UNKNOWN_OBJECT'),
        'Drop Unknown Object',
      );
    });
  });

  group('AppLocalizations meta labels', () {
    const fr = AppLocalizations(Locale('fr'));

    test('exposes inventory and map labels', () {
      expect(fr.resolveActionLabel('actions.inventory.label'), 'Inventaire');
      expect(fr.resolveActionLabel('actions.map.label'), 'Carte');
    });
  });
}
