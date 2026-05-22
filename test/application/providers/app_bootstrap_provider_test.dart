import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/application/providers/app_bootstrap_provider.dart';

void main() {
  group('appBootstrapProvider', () {
    test('returns true when read from a fresh ProviderContainer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appBootstrapProvider), isTrue);
    });
  });
}
