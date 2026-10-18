# CLAUDE.md

Flutter app **Monumental Habits** (`habit_builder`), being built to match a Figma design.

**At the start of every session read [docs/MEMORY.md](docs/MEMORY.md), [docs/RULES.md](docs/RULES.md), then [docs/PLAN.md](docs/PLAN.md).** The full doc index is [docs/README.md](docs/README.md).

**Workflow (owner rule):** work one PLAN step at a time: branch → build → ✅ in PLAN → PR → self-review → squash merge → run on the connected device → **stop and wait for the owner's "go"** before the next step.

Keep the docs current as you work:
- Record decisions, conventions and gotchas in `docs/MEMORY.md`, and add one session-log line per session.
- Update the screen status in `docs/SCREENS.md`.
- Move fixed items in `docs/KNOWN_ISSUES.md` to *Resolved*.

Commands:
- `flutter analyze` (must say *No issues found*), `flutter test`, `dart format lib test`
- Run on the test phone: `flutter run -d NNPNZLD6O7B6KVGQ` (Realme C3, 360×800 dp)
- Screenshot it: `~/Library/Android/sdk/platform-tools/adb exec-out screencap -p > shot.png`
- `flutter pub get` regenerates the localizations in `lib/l10n/gen/` (gitignored)
