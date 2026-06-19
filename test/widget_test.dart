import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breath_lab/main.dart';

void main() {
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BreathLabApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
