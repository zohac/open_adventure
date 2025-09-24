import 'package:flutter/foundation.dart';
import 'package:open_adventure/domain/repositories/save_repository.dart';
import 'package:open_adventure/domain/value_objects/game_snapshot.dart';

const _autosaveSentinel = Object();

/// Immutable view model describing the Home screen state.
@immutable
class HomeViewState {
  /// Creates a [HomeViewState] with the provided [isLoading] flag and optional
  /// [autosave] snapshot.
  const HomeViewState({
    required this.isLoading,
    required this.autosave,
  });

  /// Indicates whether the autosave lookup is currently in progress.
  final bool isLoading;

  /// Snapshot of the latest autosave, or `null` when none is available.
  final GameSnapshot? autosave;

  /// Returns a new [HomeViewState] with selectively overridden fields.
  HomeViewState copyWith({
    bool? isLoading,
    Object? autosave = _autosaveSentinel,
  }) {
    return HomeViewState(
      isLoading: isLoading ?? this.isLoading,
      autosave: identical(autosave, _autosaveSentinel)
          ? this.autosave
          : autosave as GameSnapshot?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeViewState &&
        other.isLoading == isLoading &&
        other.autosave == autosave;
  }

  @override
  int get hashCode => Object.hash(isLoading, autosave);
}

/// Application controller orchestrating the Home screen state and actions.
class HomeController extends ValueNotifier<HomeViewState> {
  /// Creates a [HomeController] backed by the provided [SaveRepository].
  HomeController({required SaveRepository saveRepository})
      : _saveRepository = saveRepository,
        super(const HomeViewState(isLoading: false, autosave: null));

  final SaveRepository _saveRepository;

  /// Refreshes the cached autosave snapshot, toggling the loading indicator
  /// while the lookup completes.
  Future<void> refreshAutosave() async {
    value = value.copyWith(isLoading: true);
    final GameSnapshot? snapshot = await _saveRepository.latest();
    value = value.copyWith(isLoading: false, autosave: snapshot);
  }
}
