import 'package:flutter/material.dart';

import '../history/history_screen.dart';

// For Phase 1B, the Progress tab shows the hold history list.
// Phase 1D will add a chart and heatmap above the list.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => const HistoryScreen();
}
