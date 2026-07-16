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

  @override
  String get historyTitle => 'História';

  @override
  String get historyEmpty => 'Zatiaľ žiadne pokusy.';

  @override
  String get historyDetailClose => 'Zavrieť';

  @override
  String get historyPbBadge => 'PB';

  @override
  String get historyFilterMax => 'Max';

  @override
  String get historyFilterTags => 'Tagy';

  @override
  String get historyFilterTagsSheetTitle => 'Filtrovať podľa tagu';

  @override
  String get historyLungVolLabel => 'Objem';

  @override
  String get historyPrepModeLabel => 'Príprava';

  @override
  String get historyPrepModeNone => 'Žiadna';

  @override
  String get historyPrepMode3s => '3s odpočítavanie';

  @override
  String get historyPrepModeShort => 'Krátke dýchanie';

  @override
  String get historyPrepModeFull => 'Plné dýchanie';

  @override
  String get historyNotesLabel => 'Poznámky';

  @override
  String get historyEditButton => 'Upraviť';

  @override
  String get historyDeleteButton => 'Vymazať';

  @override
  String get historyDeleteConfirmTitle => 'Vymazať pokus?';

  @override
  String get historyDeleteConfirmMessage => 'Túto akciu nemožno vrátiť späť.';

  @override
  String get historyCancelButton => 'Zrušiť';

  @override
  String get tablesCo2Toggle => 'CO₂';

  @override
  String get tablesO2Toggle => 'O₂';

  @override
  String tablesBasedOnMax(String max) {
    return 'Na základe maxima $max';
  }

  @override
  String get tablesNoMaxYet =>
      'Najprv zadrž dych na maximum, aby sa vygenerovala tabuľka.';

  @override
  String tablesRoundLabel(int number) {
    return 'R$number';
  }

  @override
  String get tablesHoldLabel => 'Zadržanie';

  @override
  String get tablesRestLabel => 'Oddych';

  @override
  String get tablesPhaseLabelHold => 'zadržanie';

  @override
  String get tablesPhaseLabelRest => 'oddych';

  @override
  String get tablesSummaryTitle => 'Séria dokončená';

  @override
  String tablesSummaryRounds(int completed, int total) {
    return '$completed z $total kôl dokončených';
  }

  @override
  String get tablesSummaryTotalHold => 'Celkový čas zadržania';

  @override
  String get tablesSummaryAverageHold => 'Priemerné zadržanie';

  @override
  String tablesSummaryVsPrevious(String delta) {
    return '$delta oproti minulej sérii';
  }

  @override
  String get tablesSummaryNoPrevious =>
      'Prvá séria tohto typu — zatiaľ niet s čím porovnávať.';

  @override
  String tablesHistoryRow(String type, int completed, int total, String avg) {
    return '$type tabuľka · $completed/$total kôl · priemer $avg';
  }

  @override
  String get progressStatPb => 'PB';

  @override
  String get progressStatAvg30d => '30d priemer';

  @override
  String get progressStatStreak => 'Séria';

  @override
  String get progressStatNoData => '—';

  @override
  String get progressHeatmapTitle => 'Posledných 12 týždňov';

  @override
  String get progressHeatmapLegendLess => 'Menej';

  @override
  String get progressHeatmapLegendMore => 'Viac';

  @override
  String progressHeatmapStat(int sessions, int days) {
    return '$sessions tréningov · najlepší týždeň: $days dní';
  }

  @override
  String get progressChartEmpty =>
      'Zatiaľ nedostatok pokusov na zobrazenie trendu.';

  @override
  String get progressChartFilterAll => 'Všetky';

  @override
  String get progressChartRange30d => '30d';

  @override
  String get progressChartRange90d => '90d';

  @override
  String get progressRecentHoldsTitle => 'Nedávne pokusy';

  @override
  String get progressViewAllHistory => 'Zobraziť všetko';
}
