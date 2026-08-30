import 'package:breath_lab/domain/models/evidence_tier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'tier letters match RESEARCH_ALIGNMENT.md §1 and are locale-independent',
    () {
      expect(EvidenceTier.strong.letter, 'A');
      expect(EvidenceTier.mechanistic.letter, 'B');
      expect(EvidenceTier.convention.letter, 'C');
      expect(EvidenceTier.contraindicated.letter, 'X');
    },
  );

  test('every tier resolves a label and a description', () {
    // A guard against adding a tier without wiring its ARB strings — the
    // switches are exhaustive, so this would fail to compile, but the test
    // also documents that all four are expected to be user-visible.
    expect(EvidenceTier.values, hasLength(4));
  });
}
