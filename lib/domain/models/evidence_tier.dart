import '../../l10n/app_localizations.dart';

/// How well-supported a training mode is — the four tiers from
/// `RESEARCH_ALIGNMENT.md` §1, shown to the user rather than hidden.
///
/// **The tier is not a ranking of usefulness.** A tier-C practice can be worth
/// doing; the tier states only how much confidence the evidence supports. Any
/// copy built from these values has to keep that distinction.
enum EvidenceTier {
  /// Controlled trials measuring the outcome the feature claims to improve.
  strong,

  /// The physiology is understood and the practice follows from it, but
  /// superiority over simpler alternatives is unproven or the trials are
  /// indirect.
  mechanistic,

  /// Widely practised and face-valid, with no controlled trials for this
  /// outcome.
  convention,

  /// Actively dangerous in the context the app is used in. Never a feature —
  /// only ever a warning.
  contraindicated;

  /// The single letter shown in the badge. Locale-independent and matches the
  /// tier names in `RESEARCH_ALIGNMENT.md`.
  String get letter => switch (this) {
    EvidenceTier.strong => 'A',
    EvidenceTier.mechanistic => 'B',
    EvidenceTier.convention => 'C',
    EvidenceTier.contraindicated => 'X',
  };

  /// Short label, e.g. "Strong evidence".
  String label(AppLocalizations l10n) => switch (this) {
    EvidenceTier.strong => l10n.evidenceTierStrong,
    EvidenceTier.mechanistic => l10n.evidenceTierMechanistic,
    EvidenceTier.convention => l10n.evidenceTierConvention,
    EvidenceTier.contraindicated => l10n.evidenceTierContraindicated,
  };

  /// One sentence on what the tier means — for the badge tooltip and the
  /// contextual tips added in Phase 3E.
  String description(AppLocalizations l10n) => switch (this) {
    EvidenceTier.strong => l10n.evidenceTierStrongDesc,
    EvidenceTier.mechanistic => l10n.evidenceTierMechanisticDesc,
    EvidenceTier.convention => l10n.evidenceTierConventionDesc,
    EvidenceTier.contraindicated => l10n.evidenceTierContraindicatedDesc,
  };
}
