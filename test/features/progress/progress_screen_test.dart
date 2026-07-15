import 'package:breath_lab/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Progress tab renders without layout exceptions', (tester) async {
    SharedPreferences.setMockInitialValues({'acknowledged_safety': true});

    await tester.pumpWidget(const ProviderScope(child: BreathLabApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
