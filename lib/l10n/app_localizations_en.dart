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
  String get recoveryTitle => 'Recovery breaths';

  @override
  String get recoveryBlurb =>
      'Three hook breaths — a diving habit for the first half-minute after a hold. Not shown to improve performance.';

  @override
  String get recoveryStart => 'Guide me';

  @override
  String get recoveryDone => 'Done — take it easy for a minute.';

  @override
  String get recoveryCueInhale => 'Breathe in';

  @override
  String get recoveryCueHook => 'Hook — hold';

  @override
  String get recoveryCueExhale => 'Out';

  @override
  String recoveryProgress(String cue, int breath, int total) {
    return '$cue · $breath/$total';
  }

  @override
  String get sambaResponseTitle => 'Stop training for today';

  @override
  String get sambaResponseBody =>
      'A samba — loss of motor control — is a near-blackout. Your brain was short of oxygen. Don\'t hold your breath again today, and take it easier next session.';

  @override
  String get sambaResponseSafety => 'Safety notes';

  @override
  String get sambaResponseAcknowledge => 'Got it';

  @override
  String get safetyRuleBuddy =>
      'Have someone with you who can help. One person holds while another stays alert — never both at once.';

  @override
  String get safetyRuleMedical =>
      'Get medical clearance first if you have heart disease, an arrhythmia, uncontrolled high blood pressure, epilepsy or a seizure history, are pregnant, or have ever blacked out.';

  @override
  String get safetyRulePacking =>
      'Never pack your lungs — forcing extra air in past a full breath. It can cause fainting, lung injury, and gas embolism.';

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
  String get settingsBreathingRatioRule =>
      'Exhale at least as long as the inhale, and a full cycle of 6 seconds or more.';

  @override
  String get settingsBreathingRatioTooFast =>
      'Kept as is: a cycle under 6 seconds is hyperventilation. It masks low oxygen instead of training your tolerance for it — the mechanism behind most breath-hold blackouts.';

  @override
  String get settingsBreathingRatioExhaleShort =>
      'Kept as is: a forced, shorter exhale drives the same hyperventilation the first safety screen warns about. Keep the exhale at least as long as the inhale.';

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
  String settingsTablePreviewRoundCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rounds',
      one: '1 round',
    );
    return '$_temp0';
  }

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
  String get settingsFocusModeExplanationDesktop =>
      'BreathLab will silence its own non-critical notifications during a session.';

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
  String get settingsResetSubtitle =>
      'Deletes every hold, table session and setting on this device.';

  @override
  String get settingsResetConfirmTitle => 'Reset all data?';

  @override
  String get settingsResetConfirmMessage =>
      'This deletes every hold, table session, tag, and setting on this device. This can\'t be undone.';

  @override
  String get settingsResetButton => 'Reset';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsDeviceNameLabel => 'Device name';

  @override
  String get settingsLastSyncNever => 'Never synced';

  @override
  String settingsLastSyncWith(String when, String device) {
    return 'Last synced $when with $device';
  }

  @override
  String get settingsExportButton => 'Export';

  @override
  String get settingsShareButton => 'Share';

  @override
  String get settingsImportButton => 'Import';

  @override
  String get settingsExportSuccess => 'Backup saved.';

  @override
  String get settingsExportFailed => 'Couldn\'t save the backup.';

  @override
  String get settingsImportFailedTitle => 'Import failed';

  @override
  String get settingsImportFailedMalformed =>
      'This file isn\'t a valid BreathLab backup.';

  @override
  String get settingsImportFailedFormat =>
      'This file isn\'t a BreathLab backup, or was made by an incompatible version.';

  @override
  String get settingsImportFailedSchema =>
      'This backup was made by a newer version of BreathLab. Update the app on this device first.';

  @override
  String get settingsImportFailedGeneric =>
      'Something went wrong reading this file.';

  @override
  String get settingsImportSummaryTitle => 'Import complete';

  @override
  String settingsImportSummaryBody(
    int holdsAdded,
    int sessionsAdded,
    int holdsUpdated,
    String device,
  ) {
    return 'Added $holdsAdded holds, $sessionsAdded sessions. Updated $holdsUpdated holds. Synced with $device.';
  }

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
  String get prepGetReadyLabel => 'Get ready';

  @override
  String get prepCancel => 'Cancel';

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
  String timerStatusAdherence(int percent) {
    return '$percent% this week';
  }

  @override
  String get settingsJumpTo => 'Jump to';

  @override
  String tablesEstimatedDuration(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'About $minutes minutes in total',
      one: 'About 1 minute in total',
    );
    return '$_temp0';
  }

  @override
  String get tablesSessionSummaryTitle => 'This session';

  @override
  String get timerSideLastSession => 'Last session';

  @override
  String timerSideSessionHolds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count holds',
      one: '1 hold',
    );
    return '$_temp0';
  }

  @override
  String get timerSideNoHistory =>
      'Nothing logged yet. Your first hold sets the baseline.';

  @override
  String get timerSideShortcuts => 'Shortcuts';

  @override
  String get timerSideShortcutStart => 'Start / stop hold';

  @override
  String get timerSideShortcutContraction => 'Mark contraction';

  @override
  String get timerSideShortcutCancel => 'Cancel';

  @override
  String get resultAddNote => 'Add a note';

  @override
  String get resultNoteHint => 'How did it feel?';

  @override
  String get resultRemoveNote => 'Remove note';

  @override
  String get resultNewPbBadge => 'NEW PB';

  @override
  String resultVsLast(String delta) {
    return '$delta vs last';
  }

  @override
  String resultVsPb(String delta) {
    return '$delta vs PB';
  }

  @override
  String get resultFirstHold =>
      'Your first hold — this is the baseline everything else is measured from.';

  @override
  String get resultTotal => 'Total';

  @override
  String get resultStruggleNote =>
      'Struggle phase is where most of the measured improvement in novices shows up.';

  @override
  String get resultNoContractionTitle => 'No contraction marked';

  @override
  String get resultNoContractionHintTouch =>
      'Double-tap the ring during a hold to mark your first contraction.';

  @override
  String get resultNoContractionHintKeyboard =>
      'Press C during a hold to mark your first contraction.';

  @override
  String get resultNoContractionWhy =>
      'The time from there to the end of the hold is your struggle phase — the part that tracks your progress most closely.';

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
  String get lungVolFullHint => 'Full lungs';

  @override
  String get lungVolFrcHint => 'Passive exhale';

  @override
  String get lungVolEmptyHint => 'After exhale';

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
  String historyTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

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
  String get tablesSummaryStoppedTitle => 'Session stopped';

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
  String get retestPromptTitle => 'Time to retest';

  @override
  String retestPromptBody(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: 'a week',
    );
    return 'Your last max hold was $_temp0 ago. Retest it so your CO₂ and O₂ tables stay based on a current figure.';
  }

  @override
  String get retestPromptDismiss => 'Dismiss';

  @override
  String get plateauTitle => 'Progress has stalled';

  @override
  String plateauBody(String recent, String previous) {
    return 'Your best Full-lung hold over the last four weeks ($recent) hasn\'t beaten the four weeks before ($previous).';
  }

  @override
  String get plateauAdvice =>
      'The research points to recovery and chest-wall stretching over more volume here. A one- to two-week deload is often what breaks it.';

  @override
  String get progressStatWeeksTrained => 'Weeks trained';

  @override
  String get statAbsentDuration => '——:——';

  @override
  String get statAbsentCount => '—';

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
  String get progressChartEmptyWhy =>
      'Early on, the gain shows up in the struggle phase rather than in your total time.';

  @override
  String get progressHeatmapEmpty =>
      'Twelve weeks of training will fill this in.';

  @override
  String get progressEmptyAction => 'Start a hold';

  @override
  String get progressChartEmpty =>
      'A line needs points — four sessions and the trend starts here.';

  @override
  String get progressChartStruggleLegend => 'Struggle phase';

  @override
  String get progressChartAverageLegend => 'Average';

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

  @override
  String get imstLogOpen => 'Log an IMST session';

  @override
  String get logMenuTooltip => 'Log a session';

  @override
  String get logRestMenuItem => 'Rest day';

  @override
  String get logStretchMenuItem => 'Stretching';

  @override
  String get logRestTitle => 'Log a rest day';

  @override
  String get logStretchTitle => 'Log stretching';

  @override
  String get logRestBlurb =>
      'Recovery is training. A logged rest day counts toward your week\'s structure rather than breaking a streak.';

  @override
  String get logStretchBlurb =>
      'Chest-wall stretching is the one route to a modest vital-capacity gain — single-digit percent, over months, not the half-litre of folklore.';

  @override
  String get logSessionConfirm => 'Log it';

  @override
  String get logRestSaved => 'Rest day logged';

  @override
  String get logStretchSaved => 'Stretching session logged';

  @override
  String get historyRestRow => 'Rest day';

  @override
  String get historyStretchRow => 'Stretching';

  @override
  String get imstLogTitle => 'IMST session';

  @override
  String get imstLogBreathsLabel => 'Breaths';

  @override
  String imstLogBreathsOfTarget(int target) {
    return 'of $target target';
  }

  @override
  String get imstLogLevelLabel => 'Resistance level';

  @override
  String get imstLogEvidenceNote =>
      'IMST has strong evidence for blood pressure and vascular function; its direct effect on breath-hold time is modest.';

  @override
  String get imstLogSave => 'Save session';

  @override
  String get imstLogSaved => 'IMST session saved';

  @override
  String get imstLogSaveFailed => 'Couldn\'t save the session';

  @override
  String imstDayRow(int breaths) {
    String _temp0 = intl.Intl.pluralLogic(
      breaths,
      locale: localeName,
      other: '$breaths breaths',
      one: '1 breath',
    );
    return 'IMST · $_temp0';
  }

  @override
  String imstHistoryRow(int breaths, int level) {
    String _temp0 = intl.Intl.pluralLogic(
      breaths,
      locale: localeName,
      other: '$breaths breaths',
      one: '1 breath',
    );
    return 'IMST · $_temp0 · level $level';
  }

  @override
  String get historyFilterImst => 'IMST';

  @override
  String get settingsImstGroupLabel => 'Inspiratory muscle training (IMST)';

  @override
  String get settingsImstIntro =>
      'Craighead\'s protocol: 30 resisted breaths a day, 5–6 days a week. Record how you trained, not a measurement the app can\'t take.';

  @override
  String get settingsImstDeviceNameLabel => 'Trainer';

  @override
  String get settingsImstDeviceNameHint => 'e.g. POWERbreathe Plus';

  @override
  String get settingsImstLevelLabel => 'Resistance level';

  @override
  String get settingsImstTargetLabel => 'Daily breath target';

  @override
  String get settingsImstPimaxLabel => 'PImax (cmH₂O, optional)';

  @override
  String get settingsImstPimaxNote =>
      'A numbered dial can\'t be converted to a percentage of PImax. If you have measured yours, 50% → 75% PImax is the evidence-based ramp.';

  @override
  String get tablesEvidenceNote =>
      'For novices, tables were not shown to add hypoxic or hypercapnic stress beyond plain maximal holds (Declercq & Bouten, 2024).';

  @override
  String get evidenceTierBadgePrefix => 'Evidence';

  @override
  String get evidenceTierStrong => 'Strong evidence';

  @override
  String get evidenceTierMechanistic => 'Mechanistically sound';

  @override
  String get evidenceTierConvention => 'Practice convention';

  @override
  String get evidenceTierContraindicated => 'Contraindicated';

  @override
  String get evidenceTierStrongDesc =>
      'Controlled trials measured the outcome this mode claims to improve.';

  @override
  String get evidenceTierMechanisticDesc =>
      'The physiology is understood, but its advantage over simpler training is unproven.';

  @override
  String get evidenceTierConventionDesc =>
      'Widely practised and reasonable, but not tested in controlled trials for this.';

  @override
  String get evidenceTierContraindicatedDesc =>
      'Unsafe in the way this app is used. Shown only to warn against it.';

  @override
  String get settingsResearchSummaryLink => 'Research summary';

  @override
  String get reportReaderTitle => 'Research summary';

  @override
  String get reportReaderJumpTo => 'Jump to section';

  @override
  String get reportReaderLanguageNotice =>
      'This summary is available in English only.';

  @override
  String get reportReaderLoadFailed =>
      'The research summary could not be loaded.';
}
