import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/core/utils/location_image.dart';

void main() {
  group('computeLocationImageKey', () {
    test('returns sanitized mapTag when available', () {
      expect(
        computeLocationImageKey(mapTag: 'LOC_START'),
        equals('loc_start'),
      );
    });

    test('falls back to snake_case name', () {
      expect(
        computeLocationImageKey(name: 'Well House Entrance'),
        equals('well_house_entrance'),
      );
    });

    test('falls back to id when name and mapTag are missing', () {
      expect(
        computeLocationImageKey(id: 7),
        equals('7'),
      );
    });

    test('returns "unknown" when no data is provided', () {
      expect(computeLocationImageKey(), equals('unknown'));
    });
  });

  test('imageAssetPathFromKey builds the expected path', () {
    expect(
      imageAssetPathFromKey('loc_start'),
      equals('assets/images/locations/loc_start.webp'),
    );
  });
}
