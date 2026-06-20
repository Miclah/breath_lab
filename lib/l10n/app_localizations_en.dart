// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BreathLab';

  @override
  String get navTimer => 'Timer';

  @override
  String get navTables => 'Tables';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get safetyTitle => 'Safety Information';

  @override
  String get safetyDescription =>
      'Before using BreathLab, please read and acknowledge these safety rules.';

  @override
  String get safetyRule1 => 'Never hold your breath in water while alone.';

  @override
  String get safetyRule2 => 'Never hyperventilate before a breath hold.';

  @override
  String get safetyRule3 =>
      'Stop immediately if you feel dizzy, tingling, or loss of control.';

  @override
  String get safetyAcknowledge => 'I understand';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get presetQuickMax => 'Quick max';

  @override
  String get presetStandard => 'Standard';

  @override
  String get presetFullSession => 'Full session';

  @override
  String get presetQuickMaxTooltip => 'No prep, hold immediately';

  @override
  String get presetStandardTooltip => '3-second countdown, then hold';

  @override
  String get presetFullSessionTooltip =>
      '2-minute prep with breathing guide, then hold';

  @override
  String get prepGoLabel => 'Go!';

  @override
  String get prepBreatheIn => 'Breathe in...';

  @override
  String get prepBreatheOut => 'Breathe out...';

  @override
  String get prepSkip => 'Skip →';
}
