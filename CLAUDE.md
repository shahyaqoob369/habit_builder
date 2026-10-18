# CLAUDE.md

Flutter app **Monumental Habits** (`habit_builder`), being built to match a Figma design.

**At the start of every session read [docs/MEMORY.md](docs/MEMORY.md), [docs/RULES.md](docs/RULES.md), then [docs/PLAN.md](docs/PLAN.md).** The full doc index is [docs/README.md](docs/README.md).

**Workflow (owner rule):** work one PLAN step at a time: branch → build → ✅ in PLAN → PR → self-review → squash merge → run on the connected device → **stop and wait for the owner's "go"** before the next step.

Keep the docs current as you work:
- Record decisions, conventions and gotchas in `docs/MEMORY.md`, and add one session-log line per session.
- Update the screen status in `docs/SCREENS.md`.
- Move fixed items in `docs/KNOWN_ISSUES.md` to *Resolved*.

Commands: `flutter run`, `flutter analyze`, `flutter test`. Note that `flutter analyze` and `flutter test` rewrite `pubspec.lock` through an implicit `pub get`.
