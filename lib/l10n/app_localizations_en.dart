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

  @override
  String get timerStartButton => 'Start';

  @override
  String get timerStopButton => 'Stop';

  @override
  String get timerResetButton => 'Reset';

  @override
  String get timerStateLabelHold => 'hold';

  @override
  String get timerStateLabelDone => 'done';

  @override
  String get resultSaveButton => 'Save';

  @override
  String get resultDiscardButton => 'Discard';

  @override
  String get resultContraction => 'Contraction';

  @override
  String get resultStruggle => 'Struggle';

  @override
  String get lungVolFull => 'Full';

  @override
  String get lungVolFrc => 'FRC';

  @override
  String get lungVolEmpty => 'Empty';

  @override
  String get lungVolFullHint => 'Plné pľúca · Full lungs';

  @override
  String get lungVolFrcHint => 'Pasívny výdych · Passive exhale';

  @override
  String get lungVolEmptyHint => 'Po výdychu · After exhale';

  @override
  String get tagTired => 'Tired';

  @override
  String get tagWellRested => 'Well rested';

  @override
  String get tagFullStomach => 'Full stomach';

  @override
  String get tagEmptyStomach => 'Empty stomach';

  @override
  String get tagAnxious => 'Anxious';

  @override
  String get tagGreatPrep => 'Great prep';

  @override
  String get tagSamba => 'Samba / LMC';

  @override
  String get tagCold => 'Cold';

  @override
  String get tagHot => 'Hot';

  @override
  String get tagAddLabel => '+ Add tag';

  @override
  String get historyEmpty => 'No holds saved yet.';

  @override
  String get historyDetailClose => 'Close';

  @override
  String get historyPbBadge => 'PB';

  @override
  String get historyLungVolLabel => 'Volume';
}
