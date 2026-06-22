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

  /// Settings section header for appearance options
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

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
