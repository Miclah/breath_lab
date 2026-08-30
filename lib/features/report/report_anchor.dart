/// The report anchors a contextual tip is allowed to deep-link to.
///
/// These map to `{#id}` heading ids in
/// `assets/research/breath_holding_research.md`. The ids are frozen — renaming
/// one is a breaking change, and `report_anchor_test.dart` fails if an enum
/// value here stops matching a heading in the asset.
enum ReportAnchor {
  mechanisms,
  capacity,
  methods,
  timeline,
  plan,
  safety,
  imst,
  tables;

  /// The `{#slug}` this anchor resolves to. Kept explicit rather than reusing
  /// [name] so a rename of the Dart identifier cannot silently move the link.
  String get slug => switch (this) {
    ReportAnchor.mechanisms => 'mechanisms',
    ReportAnchor.capacity => 'capacity',
    ReportAnchor.methods => 'methods',
    ReportAnchor.timeline => 'timeline',
    ReportAnchor.plan => 'plan',
    ReportAnchor.safety => 'safety',
    ReportAnchor.imst => 'imst',
    ReportAnchor.tables => 'tables',
  };
}
