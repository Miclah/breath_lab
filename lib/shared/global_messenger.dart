import 'package:flutter/material.dart';

/// App-wide [ScaffoldMessengerState] key so banners/snackbars can be shown
/// regardless of which Scaffold is currently active (normal timer, OLED
/// hold screen, or PiP) — those swap out the whole widget tree, so a
/// messenger scoped to one of them wouldn't be reachable from the others.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
