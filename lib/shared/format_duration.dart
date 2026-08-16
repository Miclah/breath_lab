/// Zero-padded `mm:ss` formatting shared by every screen that displays a
/// hold or round duration — timer, result, tables, OLED hold, and the
/// current-max field all used their own copy of this, and one of them
/// (current max) had drifted to unpadded minutes.
String formatMmSs(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
