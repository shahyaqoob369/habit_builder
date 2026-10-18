# Project Memory

The project's long-term memory. Read it at the start of every session and update it whenever something is decided or learned. Keep entries short, and keep facts that will still be true next month. Short-lived status goes in [PLAN.md](PLAN.md) or [SCREENS.md](SCREENS.md).

_Last updated: 2026-10-18_

---

## Project identity

- **Product name (in UI):** Monumental Habits. Splash and onboarding say "WELCOME TO MONUMENTAL HABITS".
- **App name constant:** `Globe.appName = "Pixel True - Habit"` in [lib/common/globe.dart](../lib/common/globe.dart).
- **Package name:** `habit_builder`. Bundle and application IDs are still the defaults: `com.example.habit_builder` (Android) and `com.example.habitBuilder` (iOS). **They must change before any store release.**
- **Design source:** the Figma file **"Pixel True – Habit Builder UI Kit"** (key `4i8xPGsRhPXs1Gs076OpeN`, last edited 2025-05-29). It has 3 pages: Introduction (promo only), **Screens (20 app screens)** and Branding Guideline (one image). It was pulled on 2026-10-18 into `docs/figma/`. See [SCREENS.md](SCREENS.md), [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) and [BACKEND_SPEC.md](BACKEND_SPEC.md).
- **App areas in the design:** onboarding, auth (login, sign up, reset), habit tracking (home grid, new habit, reminders, habit detail and analytics, congratulation), courses (list, detail with video lessons), community feed, profile stats, settings, premium subscription.
- **Goal:** build the full app so that it matches the Figma design.
- **Owner's Figma team is on the free Starter plan.**

## Toolchain (as of 2026-10-18)

- Flutter **3.41.9** stable, Dart **3.11.5**, installed at `/Users/test/Development/flutter/flutter`.
- `pubspec.yaml` SDK constraint: `^3.7.2`.
- Targets: Android, iOS, macOS, web, Linux and Windows folders all exist. **Mobile (iOS and Android) is the real target.**
- iOS and macOS now have CocoaPods (`Podfile` and `Podfile.lock`). `flutter_native_splash` is the only native plugin.

## Conventions already in the code

Follow these unless a decision below replaces them.

- **Colors:** use the static getters on `AppColor` in [lib/common/color_extensions.dart](../lib/common/color_extensions.dart). Do not hardcode hex values in screens. ⚠️ The current `AppColor` values **don't match Figma**: orange is `#FDA758`, text is plum `#573353`, background is `#FFF3E9`. The mapping is in [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md#mapping-from-the-current-code-appcolor).
- **Fonts:** the design uses **Klasik Regular** for UPPERCASE display headings. Klasik is *not* free for commercial use ("testing only; purchase for use"), so we use **Fredoka SemiBold** (OFL, family `fredoka` in pubspec) as a stand-in: **size = Klasik size × 0.83, letterSpacing = size × 0.015**. Everything else is Manrope Medium 500 / Bold 700.
- **Font:** `manrope` family is set app-wide in `ThemeData`. Bundled weights are 200, 300, 400, 500, 600, 700 and 800. **There is no 900.** `FontWeight.w900` renders as 800.
- **Navigation helpers:** `context.push(Widget)` and `context.pop()` from the `AppContext` extension.
- **Sizing helpers:** `context.width` and `context.height` (from `MediaQuery.sizeOf`).
- **Date format:** `DateTime.date` returns `yyyy/MM/dd` (needs `intl`).
- **Screen files:** `lib/screens/<feature>/<name>_screen.dart`. Each class is named `<Name>Screen` and its state class `_<Name>ScreenState`.
- **Assets:** images go in `assets/img/` (registered as a folder in the pubspec). Fonts go in `assets/font/`.
- **UI copy style:** headings in ALL CAPS, weight 800–900, navy `primaryText`.

## Decisions log

Record each decision as: date, what was decided, why.

| Date | Decision | Why |
|---|---|---|
| 2026-10-18 | Project docs live in `docs/`. `MEMORY.md` is the canonical project memory. | Requested by the project owner so context survives across sessions. |
| 2026-10-18 | Figma is the source of truth for UI. Existing screens will be reworked to match it, not kept as they are. | The current screens were built without the final design and use placeholder icons and copy. |
| 2026-10-18 | The design is pulled through the REST API (`tool/figma/figma_pull.py`) into `docs/figma/`. **All exports (`raw/`, `assets/`, `screens/`) are local-only.** Only `index.md`, `tokens.md` and `README.md` are committed. | Starter plan has no usable MCP, and the API budget is tiny, so everything is cached once. The GitHub repo is **public**, and the exports reproduce the Pixel True kit. |
| 2026-10-18 | Display font: **Fredoka SemiBold** (OFL), a static instance made from Google Fonts' variable font, replacing Klasik. | Klasik's license forbids commercial use without purchase. Fredoka was the closest of 12 open-license candidates in a side-by-side render. |
| 2026-10-18 | **Workflow:** one PLAN step = one branch, then a PR, self-review, squash merge, then run on the device, then wait for the owner's "go". Full rules are in [RULES.md](RULES.md). | Set by the owner. |
| 2026-10-18 | Plan defaults, until the owner overrides them: Firebase + RevenueCat, Riverpod + go_router, Android + iOS. | Needed to plan the 30 steps. The owner can change them before the step that uses them. |

## Gotchas and lessons

- `flutter analyze`, `flutter run` and `flutter test` run `pub get` automatically. That rewrites `pubspec.lock` to the SDK-pinned versions of the local Flutter install. Expect lockfile churn when the machine's Flutter version changes.
- The default `test/widget_test.dart` is still Flutter's counter template, so it **fails**. The splash screen also starts a 3-second `Future.delayed`, so any widget test that pumps `MyApp` must advance time or stub the splash.
- `Color.red`, `.green`, `.blue` and `.withOpacity()` are deprecated on this SDK. Use `.r`, `.g`, `.b` (0–1 doubles) and `.withValues(alpha: …)`. On this SDK `Color.a` is also a 0–1 double, so `HexColor.toHex()` is currently wrong (see KNOWN_ISSUES).
- **Figma API budget is tiny.** The owner's Figma team is on the free Starter plan, so Tier 1 REST calls (GET file, GET images) are capped at roughly 6–20 per month. Always work from the cache in `docs/figma/raw/` (made by `tool/figma/figma_pull.py`). Batch any new render into one call, and never `--force` without a reason.
- The Figma token has only the `file_content:read` scope. It can't list team files or call `/v1/me`; it needs a file link. The token is **not** stored in the repo. To pull again, the owner sets `FIGMA_TOKEN` in `~/.zshrc`. API calls used so far: 2 Tier 1 + 1 Tier 2, all on 2026-10-18.
- **The design contains placeholder copy.** Don't copy it as-is: lorem ipsum on the New Habit card and the Congratulation popup, "6-month plan for 39.99 usd" under every price, "Goggle Play", "TUE 18" twice in the week strip, and "habits makes us". Prices must come from the store.
- Each screen's `spec.txt` gives exact positions, sizes, colors and fonts, so build from the spec and use `main.png` only for a visual check. Positions are absolute, so turn them into Flutter layout (padding, rows and columns), not `Positioned` everywhere.
- Git warns about CRLF line endings: the repo was first committed with Windows line endings. This is harmless but makes diffs noisy.

## Session log

One line per session: date, what was done, where it stopped.

- **2026-10-18:** Audited the whole project and created the `docs/` folder (this file, plan, current state, screens tracker, design system, architecture, known issues). No app code changed. Waiting for the Figma connection.
- **2026-10-18:** Added the design-sharing guide (`docs/figma/README.md`: MCP, REST token or manual), the per-screen notes template, and a `BACKEND_SPEC.md` seeded from the existing screens. Waiting for the owner to choose a sharing option.
- **2026-10-18:** Pulled the whole Figma file (20 screens: PNG + spec, tokens, image fills). Reviewed every screen. Rewrote SCREENS, DESIGN_SYSTEM and BACKEND_SPEC from the real design. **Stopped at:** ready for the planning and rules session with the owner (agenda in PLAN.md). Owner questions Q1–Q17 are in BACKEND_SPEC §6. No app code changed yet.
- **2026-10-18:** Step 1: committed the baseline, added Fredoka (Klasik stand-in), wrote the 30-step PLAN and RULES. PR, merge, device run. **Next:** Step 2 (project hygiene), after the owner's "go".
