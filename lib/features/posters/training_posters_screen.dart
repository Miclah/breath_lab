import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'training_poster.dart';

/// Views the three bundled training posters with a picker and pinch-zoom, and
/// shares the current one as a PNG or the whole set as a PDF.
///
/// The posters are dark by design (they are the app on a page), so the canvas
/// stays dark here regardless of the app theme.
class TrainingPostersScreen extends StatefulWidget {
  const TrainingPostersScreen({
    super.key,
    this.initial = TrainingPoster.fullSystem,
  });

  final TrainingPoster initial;

  @override
  State<TrainingPostersScreen> createState() => _TrainingPostersScreenState();
}

class _TrainingPostersScreenState extends State<TrainingPostersScreen> {
  late TrainingPoster _poster = widget.initial;
  bool _sharing = false;

  String get _lang => Localizations.localeOf(context).languageCode;

  Future<void> _share(String assetPath, String mimeType, String name) async {
    if (_sharing) return;
    final failureMessage = AppLocalizations.of(context)!.posterShareFailed;
    setState(() => _sharing = true);
    try {
      final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mimeType, name: name)],
        ),
      );
    } catch (_) {
      scaffoldMessengerKey.currentState
        ?..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureMessage)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.posterScreenTitle),
        actions: [
          PopupMenuButton<void>(
            enabled: !_sharing,
            icon: const Icon(Icons.ios_share),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => _share(
                  _poster.imageAsset(_lang),
                  'image/png',
                  '${_poster.label(l10n)}.png',
                ),
                child: Text(l10n.posterShareImage),
              ),
              PopupMenuItem(
                onTap: () => _share(
                  trainingPosterPdfAsset(_lang),
                  'application/pdf',
                  'breathlab-posters.pdf',
                ),
                child: Text(l10n.posterSharePdf),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SegmentedButton<TrainingPoster>(
                segments: [
                  for (final p in TrainingPoster.values)
                    ButtonSegment(value: p, label: Text(p.label(l10n))),
                ],
                selected: {_poster},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _poster = s.first),
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: BreathLabColors.dark.canvas,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(64),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.sm),
                      child: Image.asset(
                        _poster.imageAsset(_lang),
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
