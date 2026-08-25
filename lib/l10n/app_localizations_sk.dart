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
  String get settingsTrainingSection => 'Tréning';

  @override
  String get settingsCurrentMaxLabel => 'Aktuálne maximum';

  @override
  String get settingsCurrentMaxInvalid => 'Zadaj platný čas (mm:ss)';

  @override
  String get settingsDefaultPrepModeLabel => 'Predvolený režim prípravy';

  @override
  String get settingsDefaultLungVolumeLabel => 'Predvolený objem pľúc';

  @override
  String get settingsTimerSection => 'Časovač';

  @override
  String get settingsPrepDurationLabel => 'Dĺžka dychovej prípravy';

  @override
  String get settingsBreathingRatioLabel => 'Pomer dýchania';

  @override
  String get settingsBreathingRatioCustom => 'Vlastný';

  @override
  String get settingsBreathingRatioInhaleLabel => 'Nádych';

  @override
  String get settingsBreathingRatioExhaleLabel => 'Výdych';

  @override
  String get settingsCo2Section => 'CO₂ tabuľka';

  @override
  String get settingsO2Section => 'O₂ tabuľka';

  @override
  String get settingsRoundsLabel => 'Kolá';

  @override
  String get settingsCo2HoldPercentLabel => '% zadržania z maxima';

  @override
  String get settingsCo2RestDecrementLabel => 'Skrátenie oddychu';

  @override
  String get settingsO2MaxHoldPercentLabel => 'Max % zadržania z maxima';

  @override
  String get settingsO2FixedRestLabel => 'Pevný oddych';

  @override
  String get settingsTablePreviewTitle => 'Náhľad';

  @override
  String get ttsMilestoneOneMinute => 'Jedna minúta';

  @override
  String get ttsMilestoneOneThirty => 'Jedna tridsať';

  @override
  String get ttsMilestoneTwoMinutes => 'Dve minúty';

  @override
  String get ttsMilestoneTwoThirty => 'Dve tridsať';

  @override
  String get ttsMilestoneThreeMinutes => 'Tri minúty';

  @override
  String get ttsMilestoneThreeThirty => 'Tri tridsať';

  @override
  String get ttsMilestoneFourMinutes => 'Štyri minúty';

  @override
  String get ttsHalfwayToPb => 'Polovica k najlepšiemu času';

  @override
  String get ttsThirtySecondsToPb => 'Tridsať sekúnd k najlepšiemu času';

  @override
  String get ttsAtPb => 'Osobný rekord';

  @override
  String get ttsPastPb => 'Nový osobný rekord';

  @override
  String get settingsAmbientSection => 'Ambientný režim';

  @override
  String get settingsAmbientIntro =>
      'BreathLab je navrhnutý tak, aby fungoval na pozadí, kým robíš niečo iné. Tieto nastavenia ti umožňujú prispôsobiť, ako sa ti aplikácia ozve počas zadržania.';

  @override
  String get settingsSpokenCalloutsLabel => 'Hlasové oznámenia';

  @override
  String get settingsCalloutsOff => 'Vypnuté';

  @override
  String get settingsCalloutsMilestones => 'Míľniky';

  @override
  String get settingsCallouts30s => '30s';

  @override
  String get settingsCallouts15s => '15s';

  @override
  String get settingsCalloutsDense => 'Husté';

  @override
  String get settingsTtsLanguageLabel => 'Jazyk hlasu';

  @override
  String get settingsTtsLanguageFollowApp => 'Podľa jazyka aplikácie';

  @override
  String get settingsTtsVoiceMissing =>
      'Slovenský hlas sa na tomto zariadení nenašiel. Kým ho nenainštaluješ v nastaveniach systému, oznámenia budú v angličtine.';

  @override
  String get settingsAmbientPersistentNotifLabel => 'Trvalá notifikácia';

  @override
  String get settingsAmbientPersistentNotifSubtitle =>
      'Živý časovač v notifikácii počas zadržania';

  @override
  String get settingsAmbientPipLabel => 'Obraz v obraze';

  @override
  String get settingsAmbientPipSubtitle =>
      'Plávajúci časovač pri prepnutí do inej aplikácie počas zadržania';

  @override
  String get settingsAmbientOledHoldLabel => 'OLED obrazovka zadržania';

  @override
  String get settingsAmbientOledHoldSubtitle =>
      'Čisto čierna, minimalistická obrazovka počas zadržania';

  @override
  String get settingsBrightnessOverrideLabel => 'Prepísanie jasu';

  @override
  String get settingsBrightnessOverrideLow => 'Nízky';

  @override
  String get settingsBrightnessOverrideCurrent => 'Aktuálny';

  @override
  String get settingsBrightnessOverrideOff => 'Vypnuté';

  @override
  String get settingsFocusModeLabel => 'Režim zamerania';

  @override
  String get settingsFocusModeExplanation =>
      'BreathLab počas tréningu stíši svoje vlastné nedôležité notifikácie. Ak chceš úplne tichý tréning, môžeš si v nastaveniach Androidu sám zapnúť režim priority — BreathLab nikdy nezasiahne do tvojho systémového nerušiť.';

  @override
  String get settingsFocusModeExplanationDesktop =>
      'BreathLab počas tréningu stíši svoje vlastné nedôležité notifikácie.';

  @override
  String get settingsSoundHapticsSection => 'Zvuk a vibrácie';

  @override
  String get settingsSoundEnabledLabel => 'Zvuk';

  @override
  String get settingsSoundVolumeLabel => 'Hlasitosť';

  @override
  String get settingsHapticIntensityLabel => 'Intenzita vibrácií';

  @override
  String get settingsHapticOff => 'Vypnuté';

  @override
  String get settingsHapticLight => 'Jemné';

  @override
  String get settingsHapticMedium => 'Stredné';

  @override
  String get settingsHapticStrong => 'Silné';

  @override
  String get settingsTestSoundButton => 'Vyskúšať zvuk';

  @override
  String get settingsTestHapticButton => 'Vyskúšať vibráciu';

  @override
  String get settingsAppearanceSection => 'Vzhľad';

  @override
  String get settingsAboutSection => 'O aplikácii';

  @override
  String get settingsSafetyInfoLink => 'Bezpečnostné informácie';

  @override
  String get settingsVersionLabel => 'Verzia';

  @override
  String get settingsResetLabel => 'Vymazať všetky dáta';

  @override
  String get settingsResetConfirmTitle => 'Vymazať všetky dáta?';

  @override
  String get settingsResetConfirmMessage =>
      'Týmto sa vymažú všetky pokusy, tabuľkové série, tagy a nastavenia v tomto zariadení. Túto akciu nemožno vrátiť späť.';

  @override
  String get settingsResetButton => 'Vymazať';

  @override
  String get settingsDataSection => 'Dáta';

  @override
  String get settingsDeviceNameLabel => 'Názov zariadenia';

  @override
  String get settingsLastSyncNever => 'Zatiaľ nesynchronizované';

  @override
  String settingsLastSyncWith(String when, String device) {
    return 'Naposledy synchronizované $when so zariadením $device';
  }

  @override
  String get settingsExportButton => 'Exportovať';

  @override
  String get settingsShareButton => 'Zdieľať';

  @override
  String get settingsImportButton => 'Importovať';

  @override
  String get settingsExportSuccess => 'Záloha uložená.';

  @override
  String get settingsExportFailed => 'Zálohu sa nepodarilo uložiť.';

  @override
  String get settingsImportFailedTitle => 'Import zlyhal';

  @override
  String get settingsImportFailedMalformed =>
      'Tento súbor nie je platná záloha BreathLab.';

  @override
  String get settingsImportFailedFormat =>
      'Tento súbor nie je záloha BreathLab, alebo bol vytvorený nekompatibilnou verziou.';

  @override
  String get settingsImportFailedSchema =>
      'Táto záloha bola vytvorená novšou verziou BreathLab. Najprv aktualizuj aplikáciu na tomto zariadení.';

  @override
  String get settingsImportFailedGeneric =>
      'Pri čítaní tohto súboru sa niečo pokazilo.';

  @override
  String get settingsImportSummaryTitle => 'Import dokončený';

  @override
  String settingsImportSummaryBody(
    int holdsAdded,
    int sessionsAdded,
    int holdsUpdated,
    String device,
  ) {
    return 'Pridaných $holdsAdded pokusov, $sessionsAdded sérií. Aktualizovaných $holdsUpdated pokusov. Synchronizované so zariadením $device.';
  }

  @override
  String get tagAddConfirm => 'Pridať';

  @override
  String get tagAddCancel => 'Zrušiť';

  @override
  String get settingsSaveFailed => 'Nastavenie sa nepodarilo uložiť.';

  @override
  String get resultSaveFailed => 'Hold sa nepodarilo uložiť. Skús to znova.';

  @override
  String get settingsThemeLabel => 'Téma';

  @override
  String get themeDark => 'Tmavá';

  @override
  String get themeLight => 'Svetlá';

  @override
  String get themeSystem => 'Systém';

  @override
  String get settingsAppLanguageLabel => 'Jazyk aplikácie';

  @override
  String get settingsLanguageSlovak => 'Slovenčina';

  @override
  String get settingsLanguageEnglish => 'Angličtina';

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
  String get prepGetReadyLabel => 'Priprav sa';

  @override
  String get prepCancel => 'Zrušiť';

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
  String get notificationMaxHoldBody => 'Max zadržanie';

  @override
  String get notificationMarkContractionAction => 'Označiť kontrakciu';

  @override
  String get notificationPermissionDeniedBanner =>
      'Povoľ notifikácie v nastaveniach systému, aby sa počas zadržania zobrazoval živý časovač.';

  @override
  String get foregroundServiceDisabledBanner =>
      'Skontroluj nastavenia optimalizácie batérie pre BreathLab, aby fungovala živá notifikácia a obraz v obraze počas zadržania.';

  @override
  String get bannerDismissAction => 'Zavrieť';

  @override
  String get timerResetButton => 'Resetovať';

  @override
  String get timerStateLabelHold => 'drž';

  @override
  String get timerStateLabelDone => 'hotovo';

  @override
  String timerStatusStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dní v rade',
      few: '$count dni v rade',
      one: '1 deň v rade',
    );
    return '$_temp0';
  }

  @override
  String get tablesSessionSummaryTitle => 'Toto sedenie';

  @override
  String get timerSideLastSession => 'Posledné sedenie';

  @override
  String timerSideSessionHolds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zadržaní',
      few: '$count zadržania',
      one: '1 zadržanie',
    );
    return '$_temp0';
  }

  @override
  String get timerSideNoHistory =>
      'Zatiaľ nič zaznamenané. Prvé zadržanie určí základ.';

  @override
  String get timerSideShortcuts => 'Klávesové skratky';

  @override
  String get timerSideShortcutStart => 'Spustiť / zastaviť zadržanie';

  @override
  String get timerSideShortcutContraction => 'Označiť kontrakciu';

  @override
  String get timerSideShortcutCancel => 'Zrušiť';

  @override
  String get resultAddNote => 'Pridať poznámku';

  @override
  String get resultNoteHint => 'Aké to bolo?';

  @override
  String get resultRemoveNote => 'Odstrániť poznámku';

  @override
  String get resultNewPbBadge => 'NOVÝ REKORD';

  @override
  String resultVsLast(String delta) {
    return '$delta oproti poslednému';
  }

  @override
  String resultVsPb(String delta) {
    return '$delta oproti rekordu';
  }

  @override
  String get resultFirstHold =>
      'Tvoje prvé zadržanie — základ, od ktorého sa všetko ďalšie meria.';

  @override
  String get resultTotal => 'Celkovo';

  @override
  String get resultStruggleNote =>
      'Fáza boja je miesto, kde sa u začiatočníkov prejaví väčšina nameraného zlepšenia.';

  @override
  String get resultNoContractionTitle => 'Kontrakcia neoznačená';

  @override
  String get resultNoContractionHintTouch =>
      'Dvojitým ťuknutím na kruh počas zadržania označíš prvú kontrakciu.';

  @override
  String get resultNoContractionHintKeyboard =>
      'Stlačením C počas zadržania označíš prvú kontrakciu.';

  @override
  String get resultNoContractionWhy =>
      'Čas odtiaľ do konca zadržania je tvoja fáza boja — tá časť, ktorá najvernejšie sleduje tvoj pokrok.';

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
  String historyTagCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tagov',
      few: '$count tagy',
      one: '1 tag',
    );
    return '$_temp0';
  }

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
  String get tablesSkipRoundButton => 'Preskočiť kolo';

  @override
  String get tablesEndSessionButton => 'Ukončiť session';

  @override
  String get tablesSummaryTitle => 'Séria dokončená';

  @override
  String get tablesSummaryStoppedTitle => 'Séria zastavená';

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
    String _temp0 = intl.Intl.pluralLogic(
      sessions,
      locale: localeName,
      other: '$sessions tréningov',
      few: '$sessions tréningy',
      one: '1 tréning',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dní',
      few: '$days dni',
      one: '1 deň',
    );
    return '$_temp0 · najlepší týždeň: $_temp1';
  }

  @override
  String get progressChartEmpty =>
      'Zatiaľ nedostatok pokusov na zobrazenie trendu.';

  @override
  String get progressChartAverageLegend => 'Priemer';

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
