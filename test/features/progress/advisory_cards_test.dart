import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/domain/services/plateau_service.dart';
import 'package:breath_lab/features/progress/plateau_card.dart';
import 'package:breath_lab/features/progress/providers.dart';
import 'package:breath_lab/features/progress/retest_prompt_card.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget card,
  List<Override> overrides,
  double width,
  Brightness b,
) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: b),
        home: Scaffold(body: SingleChildScrollView(child: card)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in const [360.0, 634.0, 1176.0]) {
    for (final b in Brightness.values) {
      testWidgets('PlateauCard renders without overflow at ${width.toInt()}px '
          '(${b.name})', (tester) async {
        await _pump(
          tester,
          const PlateauCard(),
          [
            plateauStatusProvider.overrideWithValue(
              const PlateauStatus(
                plateaued: true,
                recentBest: Duration(minutes: 2, seconds: 10),
                previousBest: Duration(minutes: 2, seconds: 15),
              ),
            ),
          ],
          width,
          b,
        );
        expect(find.byType(PlateauCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('RetestPromptCard renders and dismisses without overflow at '
          '${width.toInt()}px (${b.name})', (tester) async {
        await _pump(
          tester,
          const RetestPromptCard(),
          [
            allHoldsProvider.overrideWith((ref) async => const []),
            retestPromptProvider.overrideWith(
              (ref) async =>
                  const RetestPrompt(show: true, weeksSinceLastMax: 4),
            ),
          ],
          width,
          b,
        );
        expect(find.byType(RetestPromptCard), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
