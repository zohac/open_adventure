import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smoke provider introduced by Story 5-1 (Riverpod foundation).
///
/// Returns `true` once the [ProviderScope] is mounted, proving the wiring
/// works end-to-end. Real domain providers will be introduced in Stories
/// 5-6 → 5-10 — see `docs/dev-notes/riverpod-playbook.md`.
final Provider<bool> appBootstrapProvider = Provider<bool>(
  (ref) => true,
  name: 'appBootstrapProvider',
);
