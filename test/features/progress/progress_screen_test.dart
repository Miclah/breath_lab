import 'package:breath_lab/app.dart';
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/table_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// These tests override the data providers instead of hitting the real
// (file-backed, background-isolate) drift database: that database never
// resolves under `flutter test`'s host environment, which would otherwise
// hang every widget test that touches hold/table-session data.
List<Override> _fakeDataOverrides() => [
  allHoldsProvider.overrideWith((ref) async => const <Hold>[]),
  allTableSessionsProvider.overrideWith((ref) async => const <TableSession>[]),
  holdTagIdsProvider.overrideWith((ref) async => const <String, Set<String>>{}),
  holdTagCountsProvider.overrideWith((ref) async => const <String, int>{}),
  builtInTagsProvider.overrideWith((ref) async => const []),
];

void main() {
  testWidgets('Progress and History screens render without layout exceptions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'acknowledged_safety': true});

    await tester.pumpWidget(
      ProviderScope(
        overrides: _fakeDataOverrides(),
        child: const BreathLabApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(find.text('View all'), 200);
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
