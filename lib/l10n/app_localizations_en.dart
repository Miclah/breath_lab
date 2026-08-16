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
  String get settingsTrainingSection => 'Training';

  @override
  String get settingsCurrentMaxLabel => 'Current max';

  @override
  String get settingsCurrentMaxInvalid => 'Enter a valid time (mm:ss)';

  @override
  String get settingsDefaultPrepModeLabel => 'Default prep mode';

  @override
  String get settingsDefaultLungVolumeLabel => 'Default lung volume';

  @override
  String get settingsTimerSection => 'Timer';

  @override
  String get settingsPrepDurationLabel => 'Prep breathing duration';

  @override
  String get settingsBreathingRatioLabel => 'Breathing ratio';

  @override
  String get settingsBreathingRatioCustom => 'Custom';

  @override
  String get settingsBreathingRatioInhaleLabel => 'Inhale';

  @override
  String get settingsBreathingRatioExhaleLabel => 'Exhale';

  @override
  String get settingsCo2Section => 'CO₂ table';

  @override
  String get settingsO2Section => 'O₂ table';

  @override
  String get settingsRoundsLabel => 'Rounds';

  @override
  String get settingsCo2HoldPercentLabel => 'Hold % of max';

  @override
  String get settingsCo2RestDecrementLabel => 'Rest decrement';

  @override
  String get settingsO2MaxHoldPercentLabel => 'Max hold % of max';

  @override
  String get settingsO2FixedRestLabel => 'Fixed rest';

  @override
  String get settingsTablePreviewTitle => 'Preview';

  @override
  String get ttsMilestoneOneMinute => 'One minute';

  @override
  String get ttsMilestoneOneThirty => 'One thirty';

  @override
  String get ttsMilestoneTwoMinutes => 'Two minutes';

  @override
  String get ttsMilestoneTwoThirty => 'Two thirty';

  @override
  String get ttsMilestoneThreeMinutes => 'Three minutes';

  @override
  String get ttsMilestoneThreeThirty => 'Three thirty';

  @override
  String get ttsMilestoneFourMinutes => 'Four minutes';

  @override
  String get ttsHalfwayToPb => 'Halfway to your best';

  @override
  String get ttsThirtySecondsToPb => 'Thirty seconds to your best';

  @override
  String get ttsAtPb => 'Personal best';

  @override
  String get ttsPastPb => 'New personal best';

  @override
  String get settingsAmbientSection => 'Ambient mode';

  @override
  String get settingsAmbientIntro =>
      'BreathLab is designed to work in the background while you do something else. These settings let you tune how the app reaches you during a hold.';

  @override
  String get settingsSpokenCalloutsLabel => 'Spoken callouts';

  @override
  String get settingsCalloutsOff => 'Off';

  @override
  String get settingsCalloutsMilestones => 'Milestones';

  @override
  String get settingsCallouts30s => '30s';

  @override
  String get settingsCallouts15s => '15s';

  @override
  String get settingsCalloutsDense => 'Dense';

  @override
  String get settingsTtsLanguageLabel => 'TTS voice language';

  @override
  String get settingsTtsLanguageFollowApp => 'Follow app language';

  @override
  String get settingsTtsVoiceMissing =>
      'Slovak voice not found on this device. Callouts will use English until you install it in system settings.';

  @override
  String get settingsAmbientPersistentNotifLabel => 'Persistent notification';

  @override
  String get settingsAmbientPersistentNotifSubtitle =>
      'Live timer in a notification during a hold';

  @override
  String get settingsAmbientPipLabel => 'Picture-in-picture';

  @override
  String get settingsAmbientPipSubtitle =>
      'Floating timer when you switch apps during a hold';

  @override
  String get settingsAmbientOledHoldLabel => 'OLED hold screen';

  @override
  String get settingsAmbientOledHoldSubtitle =>
      'Pure black, minimal screen during a hold';

  @override
  String get settingsBrightnessOverrideLabel => 'Brightness override';

  @override
  String get settingsBrightnessOverrideLow => 'Low';

  @override
  String get settingsBrightnessOverrideCurrent => 'Current';

  @override
  String get settingsBrightnessOverrideOff => 'Off';

  @override
  String get settingsFocusModeLabel => 'Focus mode';

  @override
  String get settingsFocusModeExplanation =>
      'BreathLab will silence its own non-critical notifications during a session. For a fully quiet session, you can enable Priority Mode in Android Settings yourself — BreathLab will never touch your system Do Not Disturb.';

  @override
  String get settingsSoundHapticsSection => 'Sound & haptics';

  @override
  String get settingsSoundEnabledLabel => 'Sound';

  @override
  String get settingsSoundVolumeLabel => 'Volume';

  @override
  String get settingsHapticIntensityLabel => 'Haptic intensity';

  @override
  String get settingsHapticOff => 'Off';

  @override
  String get settingsHapticLight => 'Light';

  @override
  String get settingsHapticMedium => 'Medium';

  @override
  String get settingsHapticStrong => 'Strong';

  @override
  String get settingsTestSoundButton => 'Test sound';

  @override
  String get settingsTestHapticButton => 'Test haptic';

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get settingsSafetyInfoLink => 'Safety information';

  @override
  String get settingsVersionLabel => 'Version';

  @override
  String get settingsResetLabel => 'Reset all data';

  @override
  String get settingsResetConfirmTitle => 'Reset all data?';

  @override
  String get settingsResetConfirmMessage =>
      'This deletes every hold, table session, tag, and setting on this device. This can\'t be undone.';

  @override
  String get settingsResetButton => 'Reset';

  @override
  String get tagAddConfirm => 'Add';

  @override
  String get tagAddCancel => 'Cancel';

  @override
  String get settingsSaveFailed => 'Couldn\'t save that setting.';

  @override
  String get resultSaveFailed => 'Couldn\'t save that hold. Try again.';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get settingsAppLanguageLabel => 'App language';

  @override
  String get settingsLanguageSlovak => 'Slovak';

  @override
  String get settingsLanguageEnglish => 'English';

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
  String get notificationMaxHoldBody => 'Max hold';

  @override
  String get notificationMarkContractionAction => 'Mark contraction';

  @override
  String get notificationPermissionDeniedBanner =>
      'Enable notifications in system settings for live-timer overlay during holds.';

  @override
  String get foregroundServiceDisabledBanner =>
      'Check battery optimization settings for BreathLab to enable the live-timer notification and picture-in-picture during holds.';

  @override
  String get bannerDismissAction => 'Dismiss';

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
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No holds saved yet.';

  @override
  String get historyDetailClose => 'Close';

  @override
  String get historyPbBadge => 'PB';

  @override
  String get historyFilterMax => 'Max';

  @override
  String get historyFilterTags => 'Tags';

  @override
  String get historyFilterTagsSheetTitle => 'Filter by tag';

  @override
  String get historyLungVolLabel => 'Volume';

  @override
  String get historyPrepModeLabel => 'Prep';

  @override
  String get historyPrepModeNone => 'None';

  @override
  String get historyPrepMode3s => '3s countdown';

  @override
  String get historyPrepModeShort => 'Short breathing';

  @override
  String get historyPrepModeFull => 'Full breathing';

  @override
  String get historyNotesLabel => 'Notes';

  @override
  String get historyEditButton => 'Edit';

  @override
  String get historyDeleteButton => 'Delete';

  @override
  String get historyDeleteConfirmTitle => 'Delete hold?';

  @override
  String get historyDeleteConfirmMessage => 'This can\'t be undone.';

  @override
  String get historyCancelButton => 'Cancel';

  @override
  String get tablesCo2Toggle => 'CO₂';

  @override
  String get tablesO2Toggle => 'O₂';

  @override
  String tablesBasedOnMax(String max) {
    return 'Based on max $max';
  }

  @override
  String get tablesNoMaxYet => 'Do a max hold first to generate your table.';

  @override
  String tablesRoundLabel(int number) {
    return 'R$number';
  }

  @override
  String get tablesHoldLabel => 'Hold';

  @override
  String get tablesRestLabel => 'Rest';

  @override
  String get tablesPhaseLabelHold => 'hold';

  @override
  String get tablesPhaseLabelRest => 'rest';

  @override
  String get tablesSkipRoundButton => 'Skip round';

  @override
  String get tablesEndSessionButton => 'End session';

  @override
  String get tablesSummaryTitle => 'Session complete';

  @override
  String tablesSummaryRounds(int completed, int total) {
    return '$completed of $total rounds completed';
  }

  @override
  String get tablesSummaryTotalHold => 'Total hold time';

  @override
  String get tablesSummaryAverageHold => 'Average hold';

  @override
  String tablesSummaryVsPrevious(String delta) {
    return '$delta vs last session';
  }

  @override
  String get tablesSummaryNoPrevious =>
      'First session of this type — nothing to compare yet.';

  @override
  String tablesHistoryRow(String type, int completed, int total, String avg) {
    return '$type table · $completed/$total rounds · avg $avg';
  }

  @override
  String get progressStatPb => 'PB';

  @override
  String get progressStatAvg30d => '30d avg';

  @override
  String get progressStatStreak => 'Streak';

  @override
  String get progressStatNoData => '—';

  @override
  String get progressHeatmapTitle => 'Last 12 weeks';

  @override
  String get progressHeatmapLegendLess => 'Less';

  @override
  String get progressHeatmapLegendMore => 'More';

  @override
  String progressHeatmapStat(int sessions, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions sessions',
      one: '1 session',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 · best week: $_temp1';
  }

  @override
  String get progressChartEmpty => 'Not enough holds yet to show a trend.';

  @override
  String get progressChartFilterAll => 'All';

  @override
  String get progressChartRange30d => '30d';

  @override
  String get progressChartRange90d => '90d';

  @override
  String get progressRecentHoldsTitle => 'Recent holds';

  @override
  String get progressViewAllHistory => 'View all';
}
