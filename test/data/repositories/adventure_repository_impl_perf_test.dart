import 'package:flutter_test/flutter_test.dart';
import 'package:open_adventure/data/repositories/adventure_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locationById lookup average under 5ms (warm cache)', () async {
    final repo = AdventureRepositoryImpl();
    // Warm caches
    final locs = await repo.getLocations();
    expect(locs, isNotEmpty);

    final sw = Stopwatch()..start();
    const iterations = 1000;
    for (var i = 0; i < iterations; i++) {
      final id = i % locs.length;
      // ignore: unused_local_variable
      final _ = await repo.locationById(id);
    }
    sw.stop();
    final avgMs = sw.elapsedMilliseconds / iterations;
    expect(avgMs, lessThan(5.0), reason: 'Average lookup ${avgMs.toString()} ms exceeds threshold');
  });
}
