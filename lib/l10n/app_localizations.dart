import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sk'),
  ];

  /// The application title shown in the OS task switcher
  ///
  /// In en, this message translates to:
  /// **'BreathLab'**
  String get appTitle;

  /// Bottom nav label for the Timer tab
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get navTimer;

  /// Bottom nav label for the Tables tab
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get navTables;

  /// Bottom nav label for the Progress tab
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// Bottom nav label for the Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Title of the safety first-launch screen
  ///
  /// In en, this message translates to:
  /// **'Safety Information'**
  String get safetyTitle;

  /// Intro paragraph on the safety screen
  ///
  /// In en, this message translates to:
  /// **'Before using BreathLab, please read and acknowledge these safety rules.'**
  String get safetyDescription;

  /// Safety rule 1 — no solo water breath holds
  ///
  /// In en, this message translates to:
  /// **'Never hold your breath in water while alone.'**
  String get safetyRule1;

  /// Safety rule 2 — no hyperventilation
  ///
  /// In en, this message translates to:
  /// **'Never hyperventilate before a breath hold.'**
  String get safetyRule2;

  /// Safety rule 3 — stop on warning signs
  ///
  /// In en, this message translates to:
  /// **'Stop immediately if you feel dizzy, tingling, or loss of control.'**
  String get safetyRule3;

  /// Acknowledge button on the safety screen
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get safetyAcknowledge;

  /// Settings section header for training defaults
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get settingsTrainingSection;

  /// Label for the editable current max hold field in Settings
  ///
  /// In en, this message translates to:
  /// **'Current max'**
  String get settingsCurrentMaxLabel;

  /// Validation error shown below the current max field when the entered time can't be parsed
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time (mm:ss)'**
  String get settingsCurrentMaxInvalid;

  /// Label for the default prep mode selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Default prep mode'**
  String get settingsDefaultPrepModeLabel;

  /// Label for the default lung volume selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Default lung volume'**
  String get settingsDefaultLungVolumeLabel;

  /// Settings section header for prep breathing duration and ratio, shown only when default prep mode is Short or Full
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get settingsTimerSection;

  /// Label for the prep breathing duration stepper in Settings
  ///
  /// In en, this message translates to:
  /// **'Prep breathing duration'**
  String get settingsPrepDurationLabel;

  /// Label for the breathing ratio preset selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Breathing ratio'**
  String get settingsBreathingRatioLabel;

  /// Segment label that reveals custom inhale/exhale steppers for the breathing ratio
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get settingsBreathingRatioCustom;

  /// Label for the custom inhale-duration stepper
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get settingsBreathingRatioInhaleLabel;

  /// Label for the custom exhale-duration stepper
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get settingsBreathingRatioExhaleLabel;

  /// Settings section header for CO₂ table configuration
  ///
  /// In en, this message translates to:
  /// **'CO₂ table'**
  String get settingsCo2Section;

  /// Settings section header for O₂ table configuration
  ///
  /// In en, this message translates to:
  /// **'O₂ table'**
  String get settingsO2Section;

  /// Label for the rounds stepper in a table settings section
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get settingsRoundsLabel;

  /// Label for the CO₂ table hold-percentage slider
  ///
  /// In en, this message translates to:
  /// **'Hold % of max'**
  String get settingsCo2HoldPercentLabel;

  /// Label for the CO₂ table rest-decrement-per-round stepper
  ///
  /// In en, this message translates to:
  /// **'Rest decrement'**
  String get settingsCo2RestDecrementLabel;

  /// Label for the O₂ table max-hold-percentage slider
  ///
  /// In en, this message translates to:
  /// **'Max hold % of max'**
  String get settingsO2MaxHoldPercentLabel;

  /// Label for the O₂ table fixed-rest stepper
  ///
  /// In en, this message translates to:
  /// **'Fixed rest'**
  String get settingsO2FixedRestLabel;

  /// Heading above the live-computed round preview at the bottom of a table settings section
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get settingsTablePreviewTitle;

  /// Spoken TTS callout at 1:00 elapsed. Not shown as UI text — spoken in the TTS voice language, independent of the app UI language.
  ///
  /// In en, this message translates to:
  /// **'One minute'**
  String get ttsMilestoneOneMinute;

  /// Spoken TTS callout at 1:30 elapsed.
  ///
  /// In en, this message translates to:
  /// **'One thirty'**
  String get ttsMilestoneOneThirty;

  /// Spoken TTS callout at 2:00 elapsed.
  ///
  /// In en, this message translates to:
  /// **'Two minutes'**
  String get ttsMilestoneTwoMinutes;

  /// Spoken TTS callout at 2:30 elapsed.
  ///
  /// In en, this message translates to:
  /// **'Two thirty'**
  String get ttsMilestoneTwoThirty;

  /// Spoken TTS callout at 3:00 elapsed.
  ///
  /// In en, this message translates to:
  /// **'Three minutes'**
  String get ttsMilestoneThreeMinutes;

  /// Spoken TTS callout at 3:30 elapsed.
  ///
  /// In en, this message translates to:
  /// **'Three thirty'**
  String get ttsMilestoneThreeThirty;

  /// Spoken TTS callout at 4:00 elapsed.
  ///
  /// In en, this message translates to:
  /// **'Four minutes'**
  String get ttsMilestoneFourMinutes;

  /// Spoken TTS callout at half the current personal best.
  ///
  /// In en, this message translates to:
  /// **'Halfway to your best'**
  String get ttsHalfwayToPb;

  /// Spoken TTS callout 30 seconds before the current personal best.
  ///
  /// In en, this message translates to:
  /// **'Thirty seconds to your best'**
  String get ttsThirtySecondsToPb;

  /// Spoken TTS callout at the current personal best.
  ///
  /// In en, this message translates to:
  /// **'Personal best'**
  String get ttsAtPb;

  /// Spoken TTS callout just past the current personal best.
  ///
  /// In en, this message translates to:
  /// **'New personal best'**
  String get ttsPastPb;

  /// Settings section header for ambient-mode options
  ///
  /// In en, this message translates to:
  /// **'Ambient mode'**
  String get settingsAmbientSection;

  /// Intro paragraph shown above the ambient mode toggles
  ///
  /// In en, this message translates to:
  /// **'BreathLab is designed to work in the background while you do something else. These settings let you tune how the app reaches you during a hold.'**
  String get settingsAmbientIntro;

  /// Label for the spoken callouts mode selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Spoken callouts'**
  String get settingsSpokenCalloutsLabel;

  /// Spoken callouts mode: disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsCalloutsOff;

  /// Spoken callouts mode: milestones only
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get settingsCalloutsMilestones;

  /// Spoken callouts mode: every 30 seconds
  ///
  /// In en, this message translates to:
  /// **'30s'**
  String get settingsCallouts30s;

  /// Spoken callouts mode: every 15 seconds
  ///
  /// In en, this message translates to:
  /// **'15s'**
  String get settingsCallouts15s;

  /// Spoken callouts mode: dense (15s, then every 5s past 90% of PB)
  ///
  /// In en, this message translates to:
  /// **'Dense'**
  String get settingsCalloutsDense;

  /// Label for the TTS voice language selector in Settings
  ///
  /// In en, this message translates to:
  /// **'TTS voice language'**
  String get settingsTtsLanguageLabel;

  /// TTS voice language option: use whatever language the app UI is currently in
  ///
  /// In en, this message translates to:
  /// **'Follow app language'**
  String get settingsTtsLanguageFollowApp;

  /// Shown when the user picks Slovak TTS callouts but no Slovak voice is installed
  ///
  /// In en, this message translates to:
  /// **'Slovak voice not found on this device. Callouts will use English until you install it in system settings.'**
  String get settingsTtsVoiceMissing;

  /// Label for the persistent hold notification toggle in Settings (Android only)
  ///
  /// In en, this message translates to:
  /// **'Persistent notification'**
  String get settingsAmbientPersistentNotifLabel;

  /// Subtitle explaining the persistent hold notification toggle
  ///
  /// In en, this message translates to:
  /// **'Live timer in a notification during a hold'**
  String get settingsAmbientPersistentNotifSubtitle;

  /// Label for the PiP toggle in Settings (Android only)
  ///
  /// In en, this message translates to:
  /// **'Picture-in-picture'**
  String get settingsAmbientPipLabel;

  /// Subtitle explaining the PiP toggle
  ///
  /// In en, this message translates to:
  /// **'Floating timer when you switch apps during a hold'**
  String get settingsAmbientPipSubtitle;

  /// Label for the OLED-friendly hold screen toggle in Settings
  ///
  /// In en, this message translates to:
  /// **'OLED hold screen'**
  String get settingsAmbientOledHoldLabel;

  /// Subtitle explaining the OLED hold screen toggle
  ///
  /// In en, this message translates to:
  /// **'Pure black, minimal screen during a hold'**
  String get settingsAmbientOledHoldSubtitle;

  /// Label for the brightness override selector in Settings, applies during the OLED hold screen
  ///
  /// In en, this message translates to:
  /// **'Brightness override'**
  String get settingsBrightnessOverrideLabel;

  /// Brightness override option: dim the screen during the hold
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get settingsBrightnessOverrideLow;

  /// Brightness override option: leave brightness as-is
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get settingsBrightnessOverrideCurrent;

  /// Brightness override option: feature disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsBrightnessOverrideOff;

  /// Label for the focus mode toggle in Settings
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get settingsFocusModeLabel;

  /// Longer explanatory body shown below the focus mode toggle on Android, per Design Additions §7
  ///
  /// In en, this message translates to:
  /// **'BreathLab will silence its own non-critical notifications during a session. For a fully quiet session, you can enable Priority Mode in Android Settings yourself — BreathLab will never touch your system Do Not Disturb.'**
  String get settingsFocusModeExplanation;

  /// Explanatory body shown below the focus mode toggle on non-Android platforms — omits the Android Priority Mode/Do Not Disturb references
  ///
  /// In en, this message translates to:
  /// **'BreathLab will silence its own non-critical notifications during a session.'**
  String get settingsFocusModeExplanationDesktop;

  /// Settings section header for sound and haptics options
  ///
  /// In en, this message translates to:
  /// **'Sound & haptics'**
  String get settingsSoundHapticsSection;

  /// Label for the sound on/off toggle in Settings
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSoundEnabledLabel;

  /// Label for the sound volume slider in Settings
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsSoundVolumeLabel;

  /// Label for the haptic intensity selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Haptic intensity'**
  String get settingsHapticIntensityLabel;

  /// Haptic intensity option: disabled
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsHapticOff;

  /// Haptic intensity option: light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsHapticLight;

  /// Haptic intensity option: medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingsHapticMedium;

  /// Haptic intensity option: strong
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get settingsHapticStrong;

  /// Button that plays a sample audio cue at the current volume
  ///
  /// In en, this message translates to:
  /// **'Test sound'**
  String get settingsTestSoundButton;

  /// Button that plays a sample vibration at the current haptic intensity
  ///
  /// In en, this message translates to:
  /// **'Test haptic'**
  String get settingsTestHapticButton;

  /// Settings section header for appearance options
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// Settings section header for safety info, version, and reset
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// Row that opens the safety screen from Settings
  ///
  /// In en, this message translates to:
  /// **'Safety information'**
  String get settingsSafetyInfoLink;

  /// Row showing the app version and build number
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersionLabel;

  /// Row that opens the reset-all-data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset all data'**
  String get settingsResetLabel;

  /// Title of the reset-all-data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset all data?'**
  String get settingsResetConfirmTitle;

  /// Body text of the reset-all-data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This deletes every hold, table session, tag, and setting on this device. This can\'t be undone.'**
  String get settingsResetConfirmMessage;

  /// Confirm button in the reset-all-data confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetButton;

  /// Settings section header for device name, export, import, and last sync status
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// Label on the editable device name text field, shown to the other device after a sync
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get settingsDeviceNameLabel;

  /// Last-sync status line shown when this device has never exported or imported
  ///
  /// In en, this message translates to:
  /// **'Never synced'**
  String get settingsLastSyncNever;

  /// Last-sync status line shown after at least one export or import
  ///
  /// In en, this message translates to:
  /// **'Last synced {when} with {device}'**
  String settingsLastSyncWith(String when, String device);

  /// Button that opens a save dialog to write a .blab backup file
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get settingsExportButton;

  /// Android-only button that hands the backup straight to the share sheet
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get settingsShareButton;

  /// Button that opens a file picker to merge in a .blab backup file
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get settingsImportButton;

  /// Snackbar shown after a successful export
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get settingsExportSuccess;

  /// Snackbar shown when export or share fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the backup.'**
  String get settingsExportFailed;

  /// Title of the dialog shown when import fails
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get settingsImportFailedTitle;

  /// Import error: the file isn't valid JSON or is missing required fields
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a valid BreathLab backup.'**
  String get settingsImportFailedMalformed;

  /// Import error: the file's format or formatVersion isn't recognized
  ///
  /// In en, this message translates to:
  /// **'This file isn\'t a BreathLab backup, or was made by an incompatible version.'**
  String get settingsImportFailedFormat;

  /// Import error: the file's schemaVersion is newer than this device's database
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of BreathLab. Update the app on this device first.'**
  String get settingsImportFailedSchema;

  /// Import error: an unexpected failure not covered by a more specific message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading this file.'**
  String get settingsImportFailedGeneric;

  /// Title of the dialog shown after a successful import
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get settingsImportSummaryTitle;

  /// Body of the post-import summary dialog
  ///
  /// In en, this message translates to:
  /// **'Added {holdsAdded} holds, {sessionsAdded} sessions. Updated {holdsUpdated} holds. Synced with {device}.'**
  String settingsImportSummaryBody(
    int holdsAdded,
    int sessionsAdded,
    int holdsUpdated,
    String device,
  );

  /// Confirm button in the add-custom-tag dialog
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tagAddConfirm;

  /// Cancel button in the add-custom-tag dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tagAddCancel;

  /// Snackbar shown when persisting a setting change fails and the control reverts
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that setting.'**
  String get settingsSaveFailed;

  /// Snackbar shown when saving a completed hold to the database fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that hold. Try again.'**
  String get resultSaveFailed;

  /// Label for the theme selector in Settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// Dark theme option label
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Light theme option label
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// System (follow OS) theme option label
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Label for the app UI language selector in Settings
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguageLabel;

  /// App language option: Slovak
  ///
  /// In en, this message translates to:
  /// **'Slovak'**
  String get settingsLanguageSlovak;

  /// App language option: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Quick preset chip label — no prep, hold immediately
  ///
  /// In en, this message translates to:
  /// **'Quick max'**
  String get presetQuickMax;

  /// Quick preset chip label — 3-second countdown
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get presetStandard;

  /// Quick preset chip label — 2-minute prep with breathing guide
  ///
  /// In en, this message translates to:
  /// **'Full session'**
  String get presetFullSession;

  /// Long-press tooltip for the Quick max preset chip
  ///
  /// In en, this message translates to:
  /// **'No prep, hold immediately'**
  String get presetQuickMaxTooltip;

  /// Long-press tooltip for the Standard preset chip
  ///
  /// In en, this message translates to:
  /// **'3-second countdown, then hold'**
  String get presetStandardTooltip;

  /// Long-press tooltip for the Full session preset chip
  ///
  /// In en, this message translates to:
  /// **'2-minute prep with breathing guide, then hold'**
  String get presetFullSessionTooltip;

  /// Label shown at the end of the 3-second prep countdown before the hold begins
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get prepGoLabel;

  /// Label shown above the number during the 3-second prep countdown
  ///
  /// In en, this message translates to:
  /// **'Get ready'**
  String get prepGetReadyLabel;

  /// Button that aborts the 3-second prep countdown and returns to idle
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get prepCancel;

  /// Text shown inside the breathing circle during the inhale phase
  ///
  /// In en, this message translates to:
  /// **'Breathe in...'**
  String get prepBreatheIn;

  /// Text shown inside the breathing circle during the exhale phase
  ///
  /// In en, this message translates to:
  /// **'Breathe out...'**
  String get prepBreatheOut;

  /// Button that skips the prep breathing guide and starts the hold immediately
  ///
  /// In en, this message translates to:
  /// **'Skip →'**
  String get prepSkip;

  /// Action button label when timer is idle
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStartButton;

  /// Action button label during an active hold
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timerStopButton;

  /// Body text of the persistent hold notification (Android)
  ///
  /// In en, this message translates to:
  /// **'Max hold'**
  String get notificationMaxHoldBody;

  /// Action button label on the persistent hold notification (Android)
  ///
  /// In en, this message translates to:
  /// **'Mark contraction'**
  String get notificationMarkContractionAction;

  /// Banner shown during a hold when the Android notification permission was denied
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in system settings for live-timer overlay during holds.'**
  String get notificationPermissionDeniedBanner;

  /// Banner shown during a hold when the OS refused to start the foreground service, e.g. due to battery optimization
  ///
  /// In en, this message translates to:
  /// **'Check battery optimization settings for BreathLab to enable the live-timer notification and picture-in-picture during holds.'**
  String get foregroundServiceDisabledBanner;

  /// Action label to dismiss an in-app MaterialBanner
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get bannerDismissAction;

  /// Action button label in the done state before the result screen is available
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timerResetButton;

  /// State label shown below the timer number during an active hold
  ///
  /// In en, this message translates to:
  /// **'hold'**
  String get timerStateLabelHold;

  /// State label shown below the timer number after a hold is stopped
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get timerStateLabelDone;

  /// Current training streak shown in the timer status row above the preset chips
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String timerStatusStreak(int count);

  /// Heading of the settings section index in the side column
  ///
  /// In en, this message translates to:
  /// **'Jump to'**
  String get settingsJumpTo;

  /// Estimated wall-clock length of the whole table session, shown under the based-on-max line. Rounded to whole minutes — the point is the order of magnitude of the commitment, not a countdown
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{About 1 minute in total} other{About {minutes} minutes in total}}'**
  String tablesEstimatedDuration(int minutes);

  /// Heading of the tables side panel summarising the session that is about to run
  ///
  /// In en, this message translates to:
  /// **'This session'**
  String get tablesSessionSummaryTitle;

  /// Heading of the timer side panel card summarising the previous training day
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get timerSideLastSession;

  /// How many holds the previous session contained, shown beside its best time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hold} other{{count} holds}}'**
  String timerSideSessionHolds(int count);

  /// Empty state of the timer side panel's last-session card
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Your first hold sets the baseline.'**
  String get timerSideNoHistory;

  /// Heading of the keyboard shortcuts card in the timer side panel
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get timerSideShortcuts;

  /// What the Space key does on the timer screen
  ///
  /// In en, this message translates to:
  /// **'Start / stop hold'**
  String get timerSideShortcutStart;

  /// What the C key does during an active hold
  ///
  /// In en, this message translates to:
  /// **'Mark contraction'**
  String get timerSideShortcutContraction;

  /// What the Escape key does during prep, a hold, or on the result screen
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get timerSideShortcutCancel;

  /// Collapsed affordance on the result screen that expands into the notes field
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get resultAddNote;

  /// Placeholder inside the result screen notes field
  ///
  /// In en, this message translates to:
  /// **'How did it feel?'**
  String get resultNoteHint;

  /// Tooltip on the button that collapses the notes field and discards what was typed
  ///
  /// In en, this message translates to:
  /// **'Remove note'**
  String get resultRemoveNote;

  /// Pill shown above the duration on the result screen when the hold beat the previous best
  ///
  /// In en, this message translates to:
  /// **'NEW PB'**
  String get resultNewPbBadge;

  /// Comparison of this hold against the previous saved max hold; delta arrives pre-formatted as +mm:ss or −mm:ss
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last'**
  String resultVsLast(String delta);

  /// Comparison of this hold against the personal best it is measured from; delta arrives pre-formatted as +mm:ss or −mm:ss
  ///
  /// In en, this message translates to:
  /// **'{delta} vs PB'**
  String resultVsPb(String delta);

  /// Shown in place of the comparison line when there is no earlier hold to compare against
  ///
  /// In en, this message translates to:
  /// **'Your first hold — this is the baseline everything else is measured from.'**
  String get resultFirstHold;

  /// Label for the total hold duration on the result screen metrics row
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get resultTotal;

  /// Caption below the result metrics explaining why struggle-phase duration is tracked (RESEARCH_ALIGNMENT.md §2, tier A)
  ///
  /// In en, this message translates to:
  /// **'Struggle phase is where most of the measured improvement in novices shows up.'**
  String get resultStruggleNote;

  /// Heading of the result-screen card shown when the hold had no contraction marker
  ///
  /// In en, this message translates to:
  /// **'No contraction marked'**
  String get resultNoContractionTitle;

  /// How to mark a contraction, on a touch device
  ///
  /// In en, this message translates to:
  /// **'Double-tap the ring during a hold to mark your first contraction.'**
  String get resultNoContractionHintTouch;

  /// How to mark a contraction, on a device with a keyboard
  ///
  /// In en, this message translates to:
  /// **'Press C during a hold to mark your first contraction.'**
  String get resultNoContractionHintKeyboard;

  /// Why marking the contraction matters, shown below the how-to line
  ///
  /// In en, this message translates to:
  /// **'The time from there to the end of the hold is your struggle phase — the part that tracks your progress most closely.'**
  String get resultNoContractionWhy;

  /// Save button on the result screen
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get resultSaveButton;

  /// Discard button on the result screen — discards the hold without saving
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get resultDiscardButton;

  /// Label for the first-contraction time stat on the result screen
  ///
  /// In en, this message translates to:
  /// **'Contraction'**
  String get resultContraction;

  /// Label for the struggle-phase duration stat on the result screen
  ///
  /// In en, this message translates to:
  /// **'Struggle'**
  String get resultStruggle;

  /// Lung volume selector segment label for full lungs — kept as training term in both languages
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get lungVolFull;

  /// Lung volume selector segment label for functional residual capacity — training abbreviation, same in both languages
  ///
  /// In en, this message translates to:
  /// **'FRC'**
  String get lungVolFrc;

  /// Lung volume selector segment label for empty lungs — kept as training term in both languages
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get lungVolEmpty;

  /// Helper line below the lung volume selector when Full is selected
  ///
  /// In en, this message translates to:
  /// **'Full lungs'**
  String get lungVolFullHint;

  /// Helper line below the lung volume selector when FRC is selected
  ///
  /// In en, this message translates to:
  /// **'Passive exhale'**
  String get lungVolFrcHint;

  /// Helper line below the lung volume selector when Empty is selected
  ///
  /// In en, this message translates to:
  /// **'After exhale'**
  String get lungVolEmptyHint;

  /// Built-in session tag — user felt tired
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get tagTired;

  /// Built-in session tag — user felt well rested
  ///
  /// In en, this message translates to:
  /// **'Well rested'**
  String get tagWellRested;

  /// Built-in session tag — user had a full stomach
  ///
  /// In en, this message translates to:
  /// **'Full stomach'**
  String get tagFullStomach;

  /// Built-in session tag — user had an empty stomach
  ///
  /// In en, this message translates to:
  /// **'Empty stomach'**
  String get tagEmptyStomach;

  /// Built-in session tag — user felt anxious
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get tagAnxious;

  /// Built-in session tag — user had great preparation
  ///
  /// In en, this message translates to:
  /// **'Great prep'**
  String get tagGreatPrep;

  /// Built-in session tag — samba / loss of motor control occurred
  ///
  /// In en, this message translates to:
  /// **'Samba / LMC'**
  String get tagSamba;

  /// Built-in session tag — cold environment or water
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get tagCold;

  /// Built-in session tag — hot environment or water
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get tagHot;

  /// Chip at the end of the tag row — opens text input to add a custom tag
  ///
  /// In en, this message translates to:
  /// **'+ Add tag'**
  String get tagAddLabel;

  /// Title of the full history screen, pushed from the Progress screen's recent holds section
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// Empty state message on the history list
  ///
  /// In en, this message translates to:
  /// **'No holds saved yet.'**
  String get historyEmpty;

  /// Close button on the hold detail bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get historyDetailClose;

  /// Short badge label shown on a personal-best hold row
  ///
  /// In en, this message translates to:
  /// **'PB'**
  String get historyPbBadge;

  /// Type filter chip on the History screen showing standalone max holds
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get historyFilterMax;

  /// Tag count shown on a hold row in place of unlabeled dots, e.g. '2 tags'
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 tag} other{{count} tags}}'**
  String historyTagCount(int count);

  /// Filter chip on the History screen that opens the tag multi-select sheet
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get historyFilterTags;

  /// Heading of the tag multi-select bottom sheet opened from the History filter bar
  ///
  /// In en, this message translates to:
  /// **'Filter by tag'**
  String get historyFilterTagsSheetTitle;

  /// Label for the lung volume stat in the hold detail sheet
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get historyLungVolLabel;

  /// Label for the prep mode stat in the hold detail sheet
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get historyPrepModeLabel;

  /// Prep mode value: no prep, hold started immediately
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get historyPrepModeNone;

  /// Prep mode value: 3-second countdown
  ///
  /// In en, this message translates to:
  /// **'3s countdown'**
  String get historyPrepMode3s;

  /// Prep mode value: short breathing guide
  ///
  /// In en, this message translates to:
  /// **'Short breathing'**
  String get historyPrepModeShort;

  /// Prep mode value: full breathing guide
  ///
  /// In en, this message translates to:
  /// **'Full breathing'**
  String get historyPrepModeFull;

  /// Label above the notes text in the hold detail sheet
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get historyNotesLabel;

  /// Icon button tooltip/label that switches the hold detail sheet into edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get historyEditButton;

  /// Icon button tooltip/label that deletes the hold, after confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get historyDeleteButton;

  /// Title of the confirmation dialog before deleting a hold
  ///
  /// In en, this message translates to:
  /// **'Delete hold?'**
  String get historyDeleteConfirmTitle;

  /// Body text of the confirmation dialog before deleting a hold
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get historyDeleteConfirmMessage;

  /// Cancel button on the delete confirmation dialog and the edit form
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get historyCancelButton;

  /// Pill toggle segment label for the CO₂ table
  ///
  /// In en, this message translates to:
  /// **'CO₂'**
  String get tablesCo2Toggle;

  /// Pill toggle segment label for the O₂ table
  ///
  /// In en, this message translates to:
  /// **'O₂'**
  String get tablesO2Toggle;

  /// Info card text showing the current max hold the table is calculated from
  ///
  /// In en, this message translates to:
  /// **'Based on max {max}'**
  String tablesBasedOnMax(String max);

  /// Empty state shown on the Tables screen when no current max is set yet
  ///
  /// In en, this message translates to:
  /// **'Do a max hold first to generate your table.'**
  String get tablesNoMaxYet;

  /// Round number label in the table round list, e.g. R1, R2
  ///
  /// In en, this message translates to:
  /// **'R{number}'**
  String tablesRoundLabel(int number);

  /// Label for the hold duration of a table round
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get tablesHoldLabel;

  /// Label for the rest duration of a table round
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get tablesRestLabel;

  /// State label shown below the live timer on the active table round during a hold
  ///
  /// In en, this message translates to:
  /// **'hold'**
  String get tablesPhaseLabelHold;

  /// State label shown below the live timer on the active table round during rest
  ///
  /// In en, this message translates to:
  /// **'rest'**
  String get tablesPhaseLabelRest;

  /// Button on the active round card that ends its current hold/rest phase early and moves to the next round
  ///
  /// In en, this message translates to:
  /// **'Skip round'**
  String get tablesSkipRoundButton;

  /// Full-width button that ends the entire table session, as opposed to skipping just the current round
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get tablesEndSessionButton;

  /// Title of the table session summary screen when every planned round was completed
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get tablesSummaryTitle;

  /// Title of the table session summary screen when it ended early, with rounds still remaining
  ///
  /// In en, this message translates to:
  /// **'Session stopped'**
  String get tablesSummaryStoppedTitle;

  /// Rounds completed stat on the table session summary screen
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} rounds completed'**
  String tablesSummaryRounds(int completed, int total);

  /// Label for the total hold time stat on the table session summary screen
  ///
  /// In en, this message translates to:
  /// **'Total hold time'**
  String get tablesSummaryTotalHold;

  /// Label for the average hold time stat on the table session summary screen
  ///
  /// In en, this message translates to:
  /// **'Average hold'**
  String get tablesSummaryAverageHold;

  /// Comparison of average hold time to the previous same-type table session
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last session'**
  String tablesSummaryVsPrevious(String delta);

  /// Shown on the table session summary screen when there is no previous same-type session to compare against
  ///
  /// In en, this message translates to:
  /// **'First session of this type — nothing to compare yet.'**
  String get tablesSummaryNoPrevious;

  /// Single history-list row summarizing a completed table session
  ///
  /// In en, this message translates to:
  /// **'{type} table · {completed}/{total} rounds · avg {avg}'**
  String tablesHistoryRow(String type, int completed, int total, String avg);

  /// Label for the all-time personal best stat card on the Progress screen
  ///
  /// In en, this message translates to:
  /// **'PB'**
  String get progressStatPb;

  /// Label for the 30-day average hold stat card on the Progress screen
  ///
  /// In en, this message translates to:
  /// **'30d avg'**
  String get progressStatAvg30d;

  /// Label for the current streak stat card on the Progress screen
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get progressStatStreak;

  /// Placeholder value for a stat card when there is not enough history yet
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get progressStatNoData;

  /// Section header above the calendar heatmap on the Progress screen
  ///
  /// In en, this message translates to:
  /// **'Last 12 weeks'**
  String get progressHeatmapTitle;

  /// Left-hand label of the heatmap color-intensity legend
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get progressHeatmapLegendLess;

  /// Right-hand label of the heatmap color-intensity legend
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get progressHeatmapLegendMore;

  /// Summary stat shown to the right of the heatmap legend
  ///
  /// In en, this message translates to:
  /// **'{sessions, plural, =1{1 session} other{{sessions} sessions}} · best week: {days, plural, =1{1 day} other{{days} days}}'**
  String progressHeatmapStat(int sessions, int days);

  /// Empty state shown in place of the progress chart when there is no data in the selected range
  ///
  /// In en, this message translates to:
  /// **'Not enough holds yet to show a trend.'**
  String get progressChartEmpty;

  /// Legend label for the dashed daily-average line on the progress chart, shown only when a single lung volume is selected
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get progressChartAverageLegend;

  /// Lung volume filter chip label showing all volumes overlaid on the progress chart; also reused for the All time range pill
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get progressChartFilterAll;

  /// Time range pill label for the last 30 days on the progress chart
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get progressChartRange30d;

  /// Time range pill label for the last 90 days on the progress chart
  ///
  /// In en, this message translates to:
  /// **'90d'**
  String get progressChartRange90d;

  /// Section header above the last-10-holds list on the Progress screen
  ///
  /// In en, this message translates to:
  /// **'Recent holds'**
  String get progressRecentHoldsTitle;

  /// Link below the recent holds list that pushes the full history screen
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get progressViewAllHistory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
