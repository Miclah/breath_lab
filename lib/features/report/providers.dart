import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'report_markdown.dart';

/// Path to the bundled research summary. The reader and every contextual tip
/// resolve to anchors inside this one file — `RESEARCH_ALIGNMENT.md` §5.
const reportAssetPath = 'assets/research/breath_holding_research.md';

/// The parsed report, loaded from the asset bundle once and cached for the
/// process. No network, no webview — it is a file on disk.
final reportBlocksProvider = FutureProvider<List<ReportBlock>>((ref) async {
  final source = await rootBundle.loadString(reportAssetPath);
  return parseReport(source);
});
