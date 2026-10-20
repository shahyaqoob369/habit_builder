# CLAUDE.md

Flutter app **Monumental Habits** (`habit_builder`), being built to match a Figma design.

**At the start of every session read [docs/MEMORY.md](docs/MEMORY.md), [docs/RULES.md](docs/RULES.md), then [docs/PLAN.md](docs/PLAN.md).** The full doc index is [docs/README.md](docs/README.md).

**Workflow (owner rule):** work one PLAN step at a time: branch → build → ✅ in PLAN → PR → self-review → squash merge → check on the iOS Simulator → next step. Since 2026-10-20 the steps run back to back until the owner stops for a review; stop at blockers (accounts, decisions). **iPhone / App Store first**, Android after.

Keep the docs current as you work:
- Record decisions, conventions and gotchas in `docs/MEMORY.md`, and add one session-log line per session.
- Update the screen status in `docs/SCREENS.md`.
- Move fixed items in `docs/KNOWN_ISSUES.md` to *Resolved*.

Commands:
- `flutter analyze` (must say *No issues found*), `flutter test`, `dart format lib test`
- Run on the iOS Simulator: `flutter run -d <booted id>` (`xcrun simctl list devices booted`); open a screen directly with `--dart-define=INITIAL_ROUTE=/home` (debug)
- Screenshot it: `xcrun simctl io booted screenshot shot.png`
- Android test phone (later): Realme C3 `NNPNZLD6O7B6KVGQ`, screenshots with `~/Library/Android/sdk/platform-tools/adb exec-out screencap -p`
- `flutter pub get` regenerates the localizations in `lib/l10n/gen/` (gitignored)
