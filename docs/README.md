# Habit Builder — Project Docs

Docs for the **Monumental Habits** Flutter app (`habit_builder`). It is being built to match a Figma design that will be connected later.

## Start here

| Doc | What it holds | When to read it |
|---|---|---|
| [MEMORY.md](MEMORY.md) | Long-lived facts, decisions, conventions and gotchas, plus a session log | Start of **every** work session |
| [PLAN.md](PLAN.md) | **The 30-step build plan**, with ✅ marking finished steps | Before starting any step |
| [RULES.md](RULES.md) | **Working rules**: the step workflow (PR → review → merge → run on device → "go"), git, definition of done, code, assets, secrets | Before starting any step |
| [CURRENT_STATE.md](CURRENT_STATE.md) | *Historical* audit of the code before the rebuild | Only for history |
| [SCREENS.md](SCREENS.md) | Tracker that maps each screen to its Figma frame, with status | While building screens from Figma |
| [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) | Colors, type, spacing and components now in code (to be checked against Figma) | Before writing any UI |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Stack, folder layout and coding principles | Before adding files or features |
| [KNOWN_ISSUES.md](KNOWN_ISSUES.md) | Bugs and tech debt found in the audit, with file and line references | Before touching an existing screen |
| [BACKEND_SPEC.md](BACKEND_SPEC.md) | Data model, operations and business rules worked out from the design | Before building any data or auth feature |
| [figma/index.md](figma/index.md) | All 20 Figma screens, each with a PNG and an exact `spec.txt` (generated) | When building any screen |
| [figma/tokens.md](figma/tokens.md) | Raw color, type, radius and shadow counts from the design (generated) | When defining the theme |
| [figma/README.md](figma/README.md) | How the design is pulled (`tool/figma/figma_pull.py`) and the API budget | Before pulling the design again |

## Keeping these docs current

- **MEMORY.md**: add any decision, convention or non-obvious gotcha as soon as it is settled. Add one line to the session log at the end of each session.
- **SCREENS.md**: update a screen's status when work on it starts or finishes.
- **KNOWN_ISSUES.md**: when you fix an issue, move it to the *Resolved* section with the date.
- **PLAN.md**: tick off tasks and change phases when the scope changes.
- **BACKEND_SPEC.md**: add entities, fields and rules as each screen is reviewed, noting the source of each.
- Put Figma exports and notes in `docs/figma/screens/NN-screen-name/` (template: [figma/SCREEN_NOTES_TEMPLATE.md](figma/SCREEN_NOTES_TEMPLATE.md)).
