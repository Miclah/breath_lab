import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

ThemeData buildDarkTheme() =>
    _buildTheme(BreathLabColors.dark, Brightness.dark);

ThemeData buildLightTheme() =>
    _buildTheme(BreathLabColors.light, Brightness.light);

ThemeData _buildTheme(BreathLabColorScheme c, Brightness brightness) {
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: c.primary,
    onPrimary: c.textOnPrimary,
    primaryContainer: c.primarySurface,
    onPrimaryContainer: c.primaryText,
    secondary: c.primary,
    onSecondary: c.textOnPrimary,
    secondaryContainer: c.primarySurface,
    onSecondaryContainer: c.primaryText,
    error: c.danger,
    onError: c.textOnDanger,
    errorContainer: c.dangerSurface,
    onErrorContainer: c.dangerText,
    surface: c.surface,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    outline: c.border,
    outlineVariant: c.borderHover,
    scrim: Colors.black54,
    inverseSurface: c.textPrimary,
    onInverseSurface: c.canvas,
    inversePrimary: c.primaryText,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: c.canvas,
    textTheme: TextTheme(
      displayLarge: BreathLabTypography.timerDisplay.copyWith(
        color: c.textPrimary,
      ),
      headlineLarge: BreathLabTypography.headingLg.copyWith(
        color: c.textPrimary,
      ),
      headlineMedium: BreathLabTypography.headingMd.copyWith(
        color: c.textPrimary,
      ),
      headlineSmall: BreathLabTypography.headingSm.copyWith(
        color: c.textPrimary,
      ),
      bodyLarge: BreathLabTypography.bodyMd.copyWith(color: c.textPrimary),
      bodyMedium: BreathLabTypography.bodySm.copyWith(color: c.textSecondary),
      bodySmall: BreathLabTypography.caption.copyWith(color: c.textTertiary),
      labelLarge: BreathLabTypography.button.copyWith(color: c.textPrimary),
      labelMedium: BreathLabTypography.label.copyWith(color: c.textSecondary),
      labelSmall: BreathLabTypography.badge.copyWith(color: c.textTertiary),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      indicatorColor: c.primarySurface,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: c.primary);
        }
        return IconThemeData(color: c.textTertiary);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return BreathLabTypography.tabLabel.copyWith(color: c.primary);
        }
        return BreathLabTypography.tabLabel.copyWith(color: c.textTertiary);
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.canvas,
      foregroundColor: c.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: BreathLabTypography.headingMd.copyWith(
        color: c.textPrimary,
      ),
    ),
    dividerTheme: DividerThemeData(color: c.border, thickness: 0.5),
  );
}
