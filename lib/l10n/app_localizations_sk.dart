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

  @override
  String get prepBreatheIn => 'Nádych...';

  @override
  String get prepBreatheOut => 'Výdych...';

  @override
  String get prepSkip => 'Preskočiť →';

  @override
  String get timerStartButton => 'Štart';

  @override
  String get timerStopButton => 'Stop';

  @override
  String get timerResetButton => 'Resetovať';

  @override
  String get timerStateLabelHold => 'drž';

  @override
  String get timerStateLabelDone => 'hotovo';

  @override
  String get resultSaveButton => 'Uložiť';

  @override
  String get resultDiscardButton => 'Zahodiť';

  @override
  String get resultContraction => 'Kontrakcia';

  @override
  String get resultStruggle => 'Boj';

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
  String get tagTired => 'Unavený';

  @override
  String get tagWellRested => 'Oddýchnutý';

  @override
  String get tagFullStomach => 'Plný žalúdok';

  @override
  String get tagEmptyStomach => 'Prázdny žalúdok';

  @override
  String get tagAnxious => 'Nervózny';

  @override
  String get tagGreatPrep => 'Skvelá príprava';

  @override
  String get tagSamba => 'Samba / LMC';

  @override
  String get tagCold => 'Studeno';

  @override
  String get tagHot => 'Teplo';

  @override
  String get tagAddLabel => '+ Pridať tag';
}
