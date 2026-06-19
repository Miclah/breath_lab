# BreathLab

A cross-platform breath-hold training app for Windows and Android. Helps beginners to intermediate practitioners systematically improve their static apnea through evidence-based training, with full local progress tracking — no cloud, no accounts.

> Personal project. Not published to any app store.

---

## Screenshots

*Coming in Phase 1B once the timer is implemented.*

---

## How to run

**Windows:**
```
flutter run -d windows
```

**Android (emulator):**
```
flutter run -d emulator-5554
```

**Android (device):** connect via USB with developer mode enabled, then:
```
flutter run
```

**Build release APK:**
```
flutter build apk --release
```

---

## Project layout

```
lib/
  main.dart                  # entry point
  app.dart                   # MaterialApp + safety routing
  theme/                     # color tokens, spacing, typography, ThemeData
  l10n/                      # .arb files (EN + SK) and generated localizations
  features/
    shell/                   # bottom nav scaffold
    timer/                   # max hold timer (Phase 1B)
    tables/                  # CO₂ / O₂ tables (Phase 1C)
    progress/                # charts and heatmap (Phase 1D)
    settings/                # theme, language, training config (Phase 1E)
    safety/                  # first-launch safety screen
  data/                      # drift DB schema and DAOs (Phase 1B+)
  domain/                    # plain Dart models and services (Phase 1B+)
  shared/                    # reusable widgets and extensions
docs/
  BreathLab_PRD_v2.md        # product requirements
  BreathLab_Design.md        # visual design spec
  BreathLab_Design_additions.md
  phases/                    # per-phase commit plans
```

---

## Tech stack

| Concern | Package |
|---|---|
| State management | flutter_riverpod |
| Local database | drift (SQLite) |
| Charts | fl_chart |
| Audio | audioplayers |
| TTS | flutter_tts |
| Localization | flutter_localizations + intl |
| Persistence | shared_preferences |

Targets: **Windows** (`.exe`) and **Android** (`.apk`). No iOS, no web.
