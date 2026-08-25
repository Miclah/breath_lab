/// Zero-padded `mm:ss` formatting shared by every screen that displays a
/// hold or round duration — timer, result, tables, OLED hold, and the
/// current-max field all used their own copy of this, and one of them
/// (current max) had drifted to unpadded minutes.
String formatMmSs(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Signed `±mm:ss`, for a delta against a previous hold or a personal best.
///
/// Uses a real minus sign (U+2212) rather than a hyphen: the two appear in
/// the same column of the same line as a plus, and a hyphen sits visibly
/// higher and shorter than the plus it is being compared with.
String formatSignedMmSs(Duration d) =>
    '${d.isNegative ? '−' : '+'}${formatMmSs(d.abs())}';
