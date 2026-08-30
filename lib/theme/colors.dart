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
    required this.panelPrimary,
    required this.panelBorder,
    required this.quietBorder,
    required this.insetFill,
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
    required this.heatmapEmpty,
    required this.heatmapLow,
    required this.heatmapMid,
    required this.heatmapHigh,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceHover;
  final Color border;
  final Color borderHover;

  /// Fill of the primary panel — the one thing that matters on a screen.
  ///
  /// The four surface greys it replaces (`canvas`, `surface`,
  /// `surfaceElevated`, `surfaceHover`) sat inside nine points of lightness
  /// and formed an *elevation ladder*: every step lighter than the last. That
  /// gives every card the same weight and leaves a screen with no subject —
  /// the Progress screen was five boxes that looked identical because at the
  /// token level they were.
  ///
  /// Read these through `Surfaces`, not directly. The role is the API; the
  /// value is an implementation detail of it.
  final Color panelPrimary;

  /// Border of the primary panel, on three sides. The fourth — the top — is
  /// a teal hairline the role draws itself.
  final Color panelBorder;

  /// Border of a quiet panel, which has no fill at all. An outline on the
  /// field is what lets a panel recede without disappearing; with everything
  /// filled, nothing could be quiet.
  final Color quietBorder;

  /// Fill of an inset — deliberately *darker* than the field in dark mode.
  ///
  /// Depth by recessing rather than by elevating, which is also what stops
  /// nested containers from trending pale.
  final Color insetFill;

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

  /// Personal-best highlight — an achievement, not a warning.
  ///
  /// Deliberately not [danger]/[dangerText], which Design assigns to records
  /// but which this app reserves for Stop and for safety copy: a record
  /// dressed in the same red as a warning says the wrong thing about it.
  ///
  /// It was, however, set to the same value as [primaryText], which made it
  /// its own token in name only — on the Progress screen the personal best
  /// and the streak came out the same green, so two of the three stat cards
  /// were colour-coded identically. Gold is the third colour: outside the
  /// teal ramp, outside the danger red, and not [warning] either, which the
  /// timer ring uses to mean "approaching your limit".
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

  /// The four heatmap intensity steps, in order.
  ///
  /// Design Additions §1 mapped these onto `primarySurface` / `primary` /
  /// `primaryText`, which was convenient rather than legible: against the
  /// `surfaceElevated` card the empty cell and the one-session cell both
  /// land near 1.3:1, so the low end of the scale was a single state
  /// wearing two names. These are picked instead so each step roughly
  /// doubles the contrast of the one below it — about 1.3 / 1.9 / 3.7 /
  /// 7.5 against the card in both themes — which is what makes four
  /// squares read as four values rather than a smear.
  ///
  /// [heatmapEmpty] is also the only neutral one. A day with no training is
  /// a different kind of thing from a day with some, so it is off the teal
  /// ramp entirely, not merely the dim end of it.
  final Color heatmapEmpty;
  final Color heatmapLow;
  final Color heatmapMid;
  final Color heatmapHigh;
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
    panelPrimary: Color(0xFF131B25),
    panelBorder: Color(0xFF1E2733),
    quietBorder: Color(0xFF1F2836),
    insetFill: Color(0xFF070A0F),
    ringTrack: Color(0xFF545F75),
    textPrimary: Color(0xFFE8ECF1),
    textSecondary: Color(0xFF8B95A5),
    textTertiary: Color(0xFF5A6474),
    textOnPrimary: Color(0xFFEAFBF3),
    textOnDanger: Color(0xFFFDEEEE),
    primary: Color(0xFF1D9E75),
    primarySurface: Color(0xFF0D3D2E),
    primaryText: Color(0xFF5DCAA5),
    recordText: Color(0xFFE8C36A),
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
    heatmapEmpty: Color(0xFF2A3444),
    heatmapLow: Color(0xFF145840),
    heatmapMid: Color(0xFF1A8A66),
    heatmapHigh: Color(0xFF5DCAA5),
  );

  static const BreathLabColorScheme light = BreathLabColorScheme(
    canvas: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F2F5),
    surfaceHover: Color(0xFFE8EAEF),
    border: Color(0xFFD8DCE3),
    borderHover: Color(0xFFB8BFC9),
    panelPrimary: Color(0xFFFFFFFF),
    panelBorder: Color(0xFFD8DCE3),
    quietBorder: Color(0xFFD8DCE3),
    insetFill: Color(0xFFE8EAEF),
    ringTrack: Color(0xFF838D9C),
    textPrimary: Color(0xFF1A1D23),
    textSecondary: Color(0xFF5A6474),
    textTertiary: Color(0xFF8B95A5),
    textOnPrimary: Color(0xFFE1F5EE),
    textOnDanger: Color(0xFFFCEBEB),
    primary: Color(0xFF0F6E56),
    primarySurface: Color(0xFFE1F5EE),
    primaryText: Color(0xFF085041),
    recordText: Color(0xFF8A6410),
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
    heatmapEmpty: Color(0xFFCFD4DB),
    heatmapLow: Color(0xFF6FBFA2),
    heatmapMid: Color(0xFF2A8C6C),
    heatmapHigh: Color(0xFF0E5A44),
  );
}
