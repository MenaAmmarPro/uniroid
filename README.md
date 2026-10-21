# Uniroid 💕

A little universal app for **Mena** — daily tools, offline games and "us"
content, in one Android app. Built as part of
[MenaAmmarPro](https://github.com/MenaAmmarPro), the little world of love
projects.

## What's inside

**Tools**
- **Our Countdown** — days together, milestones, a date picker for "when did it all begin"
- **Calculator** — quick sums with parentheses and precedence
- **Our Diary** — one entry a day, date-seeded prompts, moods, streaks
- **Checklist** — everyday lists with progress
- **How are you?** — a gentle mood check-in with a two-week strip

**Arcade (all offline)**
- **Memory Match** — find the emoji pairs
- **Our Quiz** — 8 questions about "us"
- **2048** — slide, merge, keep going

**Us**
- **Memory Jar** — draw a random memory
- **Our Story** — five little chapters of how it began
- **65 Reasons** — a reason a day + the whole list + favourites
- Dark/light switch (her favourite is white, dark mode is there too)

Everything runs **fully offline** — content is baked into the app and state
lives in `shared_preferences` on the device. Nothing leaves the phone.

## Build

```bash
flutter pub get
flutter test          # logic suites + shell smoke test
flutter build apk     # release APK in build/app/outputs/
```

## Tech notes

- Flutter 3.x, Material 3, white-forward pink theme (`lib/theme.dart`)
- Pure game/tool logic lives in `lib/tools/*_logic.dart` and
  `lib/games/*_logic.dart` — fully unit-tested (`test/`)
- Pages under `lib/pages/`, shell navigation with push-per-feature

---

Made with 💖 — *different skies, same stars.*
