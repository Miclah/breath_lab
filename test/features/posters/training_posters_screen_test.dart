import 'package:breath_lab/features/posters/training_poster.dart';
import 'package:breath_lab/features/posters/training_posters_screen.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.dark,
}) async {
  tester.view.physicalSize = const Size(440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(brightness: brightness),
      home: const TrainingPostersScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('poster asset paths resolve by language, sk then english fallback', () {
    expect(
      TrainingPoster.fullSystem.imageAsset('sk'),
      'assets/posters/full.sk.png',
    );
    expect(
      TrainingPoster.doingAHold.imageAsset('en'),
      'assets/posters/hold.en.png',
    );
    expect(
      TrainingPoster.timeline.imageAsset('de'),
      'assets/posters/timeline.en.png',
    );
    expect(
      trainingPosterPdfAsset('sk'),
      'assets/posters/breathlab-posters.sk.pdf',
    );
  });

  testWidgets('renders with the three-way picker in both themes', (
    tester,
  ) async {
    for (final brightness in Brightness.values) {
      await _pump(tester, brightness: brightness);
      expect(tester.takeException(), isNull);
      expect(find.byType(SegmentedButton<TrainingPoster>), findsOneWidget);
      expect(find.text('Full system'), findsOneWidget);
      expect(find.text('Doing a hold'), findsOneWidget);
      expect(find.text('Timeline'), findsOneWidget);
    }
  });

  testWidgets('picking a poster swaps the shown asset', (tester) async {
    await _pump(tester);

    Image shownImage() => tester.widget<Image>(find.byType(Image));
    expect(
      (shownImage().image as AssetImage).assetName,
      'assets/posters/full.en.png',
    );

    await tester.tap(find.text('Timeline'));
    await tester.pumpAndSettle();
    expect(
      (shownImage().image as AssetImage).assetName,
      'assets/posters/timeline.en.png',
    );
  });

  testWidgets('the slovak build shows slovak poster assets', (tester) async {
    await _pump(tester, locale: const Locale('sk'));
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, 'assets/posters/full.sk.png');
    expect(find.text('Celý systém'), findsOneWidget);
  });
}
