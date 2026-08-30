import 'package:breath_lab/features/safety/safety_screen.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pump(WidgetTester tester, double width, Brightness b) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: b),
        home: const SafetyScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in const [400.0, 634.0, 1176.0]) {
    for (final b in Brightness.values) {
      testWidgets(
        'carries all five rules plus buddy and packing at ${width.toInt()}px '
        '(${b.name}), without overflow',
        (tester) async {
          await _pump(tester, width, b);
          final l10n = await AppLocalizations.delegate.load(const Locale('en'));

          for (final rule in [
            l10n.safetyRule1,
            l10n.safetyRule2,
            l10n.safetyRule3,
            l10n.safetyRuleBuddy,
            l10n.safetyRuleMedical,
            l10n.safetyRulePacking,
          ]) {
            expect(
              find.text(rule),
              findsOneWidget,
              reason: 'missing safety rule: $rule',
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
