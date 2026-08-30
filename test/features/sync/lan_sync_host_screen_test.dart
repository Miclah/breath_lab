import 'package:breath_lab/domain/models/lan_pairing.dart';
import 'package:breath_lab/domain/services/lan_sync_host.dart';
import 'package:breath_lab/domain/services/sync_merge_service.dart';
import 'package:breath_lab/domain/services/sync_service.dart';
import 'package:breath_lab/features/sync/lan_sync_host_screen.dart';
import 'package:breath_lab/features/sync/lan_sync_providers.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _pairing = LanPairing(
  hosts: ['192.168.1.20'],
  port: 51000,
  token: 'tok',
  deviceName: 'The PC',
);

Future<void> _pump(
  WidgetTester tester,
  Stream<LanSyncHostStatus> stream, {
  Brightness brightness = Brightness.dark,
}) async {
  tester.view.physicalSize = const Size(500, 1000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [lanSyncHostStatusProvider.overrideWith((ref) => stream)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: brightness),
        home: const LanSyncHostScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('serving state shows the QR and the plaintext notice', (t) async {
    await _pump(t, Stream.value(LanSyncServing(_pairing)));
    expect(find.textContaining('scan this code'), findsOneWidget);
    expect(
      find.text(
        'Anyone on this Wi-Fi network can see the transfer while it runs.',
      ),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('serving state renders in light theme too', (t) async {
    await _pump(
      t,
      Stream.value(LanSyncServing(_pairing)),
      brightness: Brightness.light,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('done state shows the summary and a close button', (t) async {
    const summary = SyncImportSummary(
      counts: MergeCounts(holdsAdded: 2, sessionsAdded: 1),
      peerDeviceName: 'Pixel',
    );
    await _pump(t, Stream.value(const LanSyncHostDone(summary)));
    expect(find.text('Sync complete'), findsOneWidget);
    expect(find.textContaining('Pixel'), findsOneWidget);
  });

  testWidgets('failed state offers a retry', (t) async {
    await _pump(
      t,
      Stream.value(const LanSyncHostFailed('No device connected.')),
    );
    expect(find.text('No device connected.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
