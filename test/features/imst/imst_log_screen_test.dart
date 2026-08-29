import 'package:breath_lab/data/db/app_database.dart';
import 'package:breath_lab/data/db/database_provider.dart';
import 'package:breath_lab/features/imst/imst_log_screen.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The visual pass the last three phases kept deferring, in the form a
/// `flutter test` run can actually assert: pump the new screen at each
/// target width in both themes and fail on any layout overflow.
Future<void> _pump(
  WidgetTester tester,
  double width,
  Brightness brightness,
) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(
          AppDatabase.forTesting(NativeDatabase.memory()),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: brightness),
        home: const ImstLogScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in const [400.0, 634.0, 1176.0, 2560.0]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'ImstLogScreen lays out without overflow at ${width.toInt()}px '
        '(${brightness.name})',
        (tester) async {
          await _pump(tester, width, brightness);

          expect(find.byType(ImstLogScreen), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('the breath counter increments and enables save', (tester) async {
    await _pump(tester, 634, Brightness.dark);

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final save = find.widgetWithText(FilledButton, l10n.imstLogSave);
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pump();

    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    expect(find.text('1'), findsOneWidget);
  });
}
