# Monumental Habits

A habit-building app in Flutter: *building habits, one step at a time.* It is built screen by screen from the "Pixel True – Habit Builder" Figma design.

## Getting started

Requirements: Flutter **3.41+** (Dart 3.11+), Android Studio or Xcode.

```bash
flutter pub get          # also generates the localizations in lib/l10n/gen
flutter run              # pick a device
flutter analyze          # must report: No issues found
flutter test
```

The Firebase config files are kept out of this public repo. To build the app, generate them first ([docs/FIREBASE.md](docs/FIREBASE.md)). The RevenueCat SDK keys are kept out the same way ([docs/REVENUECAT.md](docs/REVENUECAT.md)). To only analyze and test, copy the placeholders: `cp tool/ci/firebase_options_stub.dart lib/firebase_options.dart` and `cp tool/ci/revenuecat_options_stub.dart lib/revenuecat_options.dart`.

CI (GitHub Actions, [`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs the format check, `flutter analyze` and `flutter test` on every pull request and on `main`.

## Project docs

Everything about the project lives in [`docs/`](docs/README.md):

- [PLAN.md](docs/PLAN.md): the step-by-step build plan and progress
- [RULES.md](docs/RULES.md): workflow, git, definition of done, code rules
- [ARCHITECTURE.md](docs/ARCHITECTURE.md): stack and folder layout
- [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md): colors, typography, components from Figma
- [BACKEND_SPEC.md](docs/BACKEND_SPEC.md): data model and business rules

## Fonts

- [Manrope](https://fonts.google.com/specimen/Manrope) for body text.
- [Fredoka](https://fonts.google.com/specimen/Fredoka) for display headings, standing in for the design's Klasik. License: SIL OFL 1.1, see `assets/font/OFL-Fredoka.txt`.
