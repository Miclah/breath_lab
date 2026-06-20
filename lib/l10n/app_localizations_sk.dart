// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'BreathLab';

  @override
  String get navTimer => 'Časovač';

  @override
  String get navTables => 'Tabuľky';

  @override
  String get navProgress => 'Pokrok';

  @override
  String get navSettings => 'Nastavenia';

  @override
  String get safetyTitle => 'Bezpečnostné informácie';

  @override
  String get safetyDescription =>
      'Pred použitím BreathLab si prečítaj a potvrď tieto bezpečnostné pravidlá.';

  @override
  String get safetyRule1 => 'Nikdy nezadržiavaj dych vo vode sám/sama.';

  @override
  String get safetyRule2 => 'Nikdy nehyperventiluj pred zadržaním dychu.';

  @override
  String get safetyRule3 =>
      'Okamžite prestaň, ak pocítiš závraty, mravčenie alebo stratu kontroly.';

  @override
  String get safetyAcknowledge => 'Rozumiem';

  @override
  String get settingsAppearanceSection => 'Vzhľad';

  @override
  String get settingsThemeLabel => 'Téma';

  @override
  String get themeDark => 'Tmavá';

  @override
  String get themeLight => 'Svetlá';

  @override
  String get themeSystem => 'Systém';

  @override
  String get presetQuickMax => 'Rýchly max';

  @override
  String get presetStandard => 'Štandard';

  @override
  String get presetFullSession => 'Plné sedenie';

  @override
  String get presetQuickMaxTooltip => 'Bez prípravy, ihneď zadrž dych';

  @override
  String get presetStandardTooltip =>
      '3-sekundové odpočítavanie, potom zadrž dych';

  @override
  String get presetFullSessionTooltip =>
      '2-minútová príprava s dychovým sprievodcom, potom zadrž dych';

  @override
  String get prepGoLabel => 'Štart!';
}
