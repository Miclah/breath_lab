import 'package:flutter/material.dart';

/// Pure OLED black, used for PiP and the OLED hold screen — intentionally
/// the same in both light and dark theme, not a themed token.
const oledBlack = Color(0xFF000000);

extension BreathLabTheme on BuildContext {
  BreathLabColorScheme get appColors =>
      Theme.of(this).brightness == Brightness.dark
      ? BreathLabColors.dark
      : BreathLabColors.light;
}

class BreathLabColorScheme {
  const BreathLabColorScheme({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHover,
    required this.border,
    required this.borderHover,
    required this.ringTrack,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.textOnDanger,
    required this.primary,
    required this.primarySurface,
    required this.primaryText,
    required this.recordText,
    required this.warning,
    required this.warningSurface,
    required this.warningText,
    required this.danger,
    required this.dangerSurface,
    required this.dangerText,
    required this.info,
    required this.infoSurface,
    required this.infoText,
    required this.success,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHover;
  final Color border;
  final Color borderHover;

  /// The unfilled part of the timer ring.
  ///
  /// Not a border tint. A single alpha over [border] cannot serve two
  /// canvases: the same value that reads on the light canvas composites to
  /// almost nothing on `#0A0E14`, which left the idle ring invisible in the
  /// mode the app is used in most. Each theme names its own colour, chosen
  /// so the track clears 3:1 against its canvas — the contrast floor for a
  /// graphical object — while the teal arc sits near 5.75:1 in both. The
  /// arc stays the louder of the two by the same margin either way.
  final Color ringTrack;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color textOnDanger;
  final Color primary;
  final Color primarySurface;
  final Color primaryText;

  /// Personal-best highlight — an achievement, not a warning. Deliberately
  /// its own token rather than reusing [danger]/[dangerText], which is
  /// reserved for Stop and real warnings.
  final Color recordText;

  final Color warning;
  final Color warningSurface;
  final Color warningText;
  final Color danger;
  final Color dangerSurface;
  final Color dangerText;
  final Color info;
  final Color infoSurface;
  final Color infoText;
  final Color success;
}

class BreathLabColors {
  const BreathLabColors._();

  static const BreathLabColorScheme dark = BreathLabColorScheme(
    canvas: Color(0xFF0A0E14),
    surface: Color(0xFF111820),
    surfaceElevated: Color(0xFF1A2230),
    surfaceHover: Color(0xFF222A38),
    border: Color(0xFF252D3A),
    borderHover: Color(0xFF354050),
    ringTrack: Color(0xFF545F75),
    textPrimary: Color(0xFFE8ECF1),
    textSecondary: Color(0xFF8B95A5),
    textTertiary: Color(0xFF5A6474),
    textOnPrimary: Color(0xFFEAFBF3),
    textOnDanger: Color(0xFFFDEEEE),
    primary: Color(0xFF1D9E75),
    primarySurface: Color(0xFF0D3D2E),
    primaryText: Color(0xFF5DCAA5),
    recordText: Color(0xFF5DCAA5),
    warning: Color(0xFFEF9F27),
    warningSurface: Color(0xFF3D2A08),
    warningText: Color(0xFFFAC775),
    danger: Color(0xFFE24B4A),
    dangerSurface: Color(0xFF3D1414),
    dangerText: Color(0xFFF09595),
    info: Color(0xFF378ADD),
    infoSurface: Color(0xFF0C2440),
    infoText: Color(0xFF85B7EB),
    success: Color(0xFF639922),
  );

  static const BreathLabColorScheme light = BreathLabColorScheme(
    canvas: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F2F5),
    surfaceHover: Color(0xFFE8EAEF),
    border: Color(0xFFD8DCE3),
    borderHover: Color(0xFFB8BFC9),
    ringTrack: Color(0xFF838D9C),
    textPrimary: Color(0xFF1A1D23),
    textSecondary: Color(0xFF5A6474),
    textTertiary: Color(0xFF8B95A5),
    textOnPrimary: Color(0xFFE1F5EE),
    textOnDanger: Color(0xFFFCEBEB),
    primary: Color(0xFF0F6E56),
    primarySurface: Color(0xFFE1F5EE),
    primaryText: Color(0xFF085041),
    recordText: Color(0xFF085041),
    warning: Color(0xFFBA7517),
    warningSurface: Color(0xFFFAEEDA),
    warningText: Color(0xFF633806),
    danger: Color(0xFFA32D2D),
    dangerSurface: Color(0xFFFCEBEB),
    dangerText: Color(0xFF791F1F),
    info: Color(0xFF185FA5),
    infoSurface: Color(0xFFE6F1FB),
    infoText: Color(0xFF0C447C),
    success: Color(0xFF3B6D11),
  );
}
