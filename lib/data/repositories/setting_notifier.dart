import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';

/// Base for a single persisted setting.
///
/// Settings used to be plain [FutureProvider]s that the UI re-read after
/// every write (`await repo.setX(); ref.invalidate(provider)`). That made
/// each control unable to move until a full round-trip through drift had
/// completed — and on Android drift runs in a background isolate, so a
/// slider being dragged could not track the finger at all, and a failed
/// write was completely silent. Here [set] updates [state] first and
/// persists afterwards, so the UI always responds immediately and a
/// failure is rolled back and reported instead of swallowed.
abstract class SettingNotifier<T> extends AsyncNotifier<T> {
  /// Loads the persisted value.
  Future<T> read();

  /// Persists [value].
  Future<void> write(T value);

  @override
  Future<T> build() => read();

  // Writes are chained rather than fired independently: drift's single
  // writer means completion order is not guaranteed to match call order,
  // so two rapid set() calls could otherwise persist out of order and
  // leave the DB holding a stale value the UI never shows again until
  // restart. Chaining also means an older write's failure can't roll a
  // newer, already-succeeded write back — see the generation check below.
  Future<void> _pendingWrites = Future.value();
  int _generation = 0;

  /// Applies [value] to the UI immediately, then persists it. If the write
  /// fails — and no later [set] call has already superseded this one — the
  /// previous value is restored and the user is told.
  Future<void> set(T value) async {
    final generation = ++_generation;
    final previous = state;
    state = AsyncData(value);

    final thisWrite = _pendingWrites.then((_) => write(value));
    _pendingWrites = thisWrite.then((_) {}, onError: (_) {});

    try {
      await thisWrite;
    } catch (error, stackTrace) {
      if (generation == _generation) {
        state = previous;
      }
      _reportFailure(error, stackTrace);
    }
  }

  void _reportFailure(Object error, StackTrace stackTrace) {
    debugPrint('Failed to persist setting: $error\n$stackTrace');
    final messenger = scaffoldMessengerKey.currentState;
    final context = messenger?.context;
    if (messenger == null || context == null) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.settingsSaveFailed)));
  }
}
