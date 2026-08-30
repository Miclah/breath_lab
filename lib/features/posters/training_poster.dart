import '../../l10n/app_localizations.dart';

/// The three bundled training posters (`assets/posters/`). Each ships as an A4
/// PNG in English and Slovak, rendered from the design canvas; the whole set
/// is also bundled as one PDF per language. The poster artwork is baked in —
/// only the picker labels and screen chrome go through the ARB files.
enum TrainingPoster {
  fullSystem,
  doingAHold,
  timeline;

  String get _slug => switch (this) {
    TrainingPoster.fullSystem => 'full',
    TrainingPoster.doingAHold => 'hold',
    TrainingPoster.timeline => 'timeline',
  };

  /// `en` or `sk` — every other locale falls back to English, matching the
  /// research reader's English-only treatment.
  static String posterLang(String languageCode) =>
      languageCode == 'sk' ? 'sk' : 'en';

  String imageAsset(String languageCode) =>
      'assets/posters/$_slug.${posterLang(languageCode)}.png';

  String label(AppLocalizations l10n) => switch (this) {
    TrainingPoster.fullSystem => l10n.posterFullSystem,
    TrainingPoster.doingAHold => l10n.posterDoingAHold,
    TrainingPoster.timeline => l10n.posterTimeline,
  };
}

/// The whole poster set as one PDF, in the app's language where available.
String trainingPosterPdfAsset(String languageCode) =>
    'assets/posters/breathlab-posters.${TrainingPoster.posterLang(languageCode)}.pdf';
