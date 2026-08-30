import 'package:breath_lab/features/report/providers.dart';
import 'package:breath_lab/features/report/report_anchor.dart';
import 'package:breath_lab/features/report/report_markdown.dart';
import 'package:breath_lab/features/report/report_reader_screen.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:breath_lab/shared/widgets/contextual_tip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Brightness brightness) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reportBlocksProvider.overrideWith(
          (ref) async => parseReport('# R\n\n## Tables {#tables}\n\nBody.'),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: brightness),
        home: const Scaffold(
          body: ContextualTip(
            text: 'Tables are not proven better than plain maximal holds.',
            anchor: ReportAnchor.tables,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('renders the excerpt at ${brightness.name}', (tester) async {
      await _pump(tester, brightness);
      expect(find.textContaining('not proven better'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('read more opens the reader at the tip anchor', (tester) async {
    await _pump(tester, Brightness.dark);
    await tester.tap(find.text('Read more'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportReaderScreen), findsOneWidget);
  });
}
