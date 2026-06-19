import 'package:flutter/material.dart';

class BreathLabColorScheme {
  const BreathLabColorScheme({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceHover,
    required this.border,
    required this.borderHover,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.textOnDanger,
    required this.primary,
    required this.primarySurface,
    required this.primaryText,
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
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color textOnDanger;
  final Color primary;
  final Color primarySurface;
  final Color primaryText;
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
    textPrimary: Color(0xFFE8ECF1),
    textSecondary: Color(0xFF8B95A5),
    textTertiary: Color(0xFF5A6474),
    textOnPrimary: Color(0xFF04342C),
    textOnDanger: Color(0xFF501313),
    primary: Color(0xFF1D9E75),
    primarySurface: Color(0xFF0D3D2E),
    primaryText: Color(0xFF5DCAA5),
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
}
