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
- **Test device: Realme C3** (Android 10, id `NNPNZLD6O7B6KVGQ`, 720×1600 px at density 320, which is **360 × 800 dp**, narrower than the 414 dp design). adb is at `~/Library/Android/sdk/platform-tools/adb`; it's not on PATH. The owner's iPhones are paired but need a cable and Developer Mode.
- iOS and macOS now have CocoaPods (`Podfile` and `Podfile.lock`). `flutter_native_splash` is the only native plugin.

## Conventions (since step 2)

The full rules are in [RULES.md](RULES.md) and [ARCHITECTURE.md](ARCHITECTURE.md). The essentials:

- **Feature-first layout:** `lib/app` (app, router, theme), `lib/core` (extensions, shared widgets), `lib/features/<area>/{presentation,application,domain,data}`, `lib/l10n`.
- **Colors:** `context.colors.<token>` (an `AppColors` ThemeExtension). Never use `AppPalette` or hex values in widgets.
- **Text:** `AppTextStyles.<style>` (the color comes from the theme). Display headings use Fredoka and are uppercased in code.
- **Spacing, radii, shadows:** `AppSpacing`, `AppRadii`, `AppShadows`. The screen padding is `AppSpacing.screen` (20).
- **Strings:** `lib/l10n/arb/app_en.arb`, read with `context.l10n.key`. The generated files in `lib/l10n/gen/` are gitignored and rebuilt by `flutter pub get`.
- **Routes:** add them to the `AppRoute` enum in `lib/app/router/app_router.dart` and navigate with `context.goNamed(AppRoute.x.name)`.
- **Lints:** `very_good_analysis`. `flutter analyze` must say *No issues found*. Run `dart format` before committing.
- **Tests:** `test/` mirrors `lib/`. Wrap widgets with `tester.pumpApp(...)` from `test/helpers/pump_app.dart`.
- **Fonts:** families `Manrope` (500 and 700 only) and `Fredoka` (600).

## Decisions log

Record each decision as: date, what was decided, why.

| Date | Decision | Why |
|---|---|---|
| 2026-10-18 | Project docs live in `docs/`. `MEMORY.md` is the canonical project memory. | Requested by the project owner so context survives across sessions. |
| 2026-10-18 | Figma is the source of truth for UI. Existing screens will be reworked to match it, not kept as they are. | The current screens were built without the final design and use placeholder icons and copy. |
| 2026-10-18 | The design is pulled through the REST API (`tool/figma/figma_pull.py`) into `docs/figma/`. **All exports (`raw/`, `assets/`, `screens/`) are local-only.** Only `index.md`, `tokens.md` and `README.md` are committed. | Starter plan has no usable MCP, and the API budget is tiny, so everything is cached once. The GitHub repo is **public**, and the exports reproduce the Pixel True kit. |
| 2026-10-18 | Display font: **Fredoka SemiBold** (OFL), a static instance made from Google Fonts' variable font, replacing Klasik. | Klasik's license forbids commercial use without purchase. Fredoka was the closest of 12 open-license candidates in a side-by-side render. |
| 2026-10-18 | **Workflow:** one PLAN step = one branch, then a PR, self-review, squash merge, then run on the device, then wait for the owner's "go". Full rules are in [RULES.md](RULES.md). | Set by the owner. |
| 2026-10-18 | **Rebuild the UI from scratch, UI first** (sample data), then connect the backend. Old screens were deleted in step 2. | Owner: "start on the UI from scratch… pixel perfect… best practice". |
| 2026-10-18 | Stack: very_good_analysis, Riverpod 3, go_router 17, gen-l10n, theme tokens with an `AppColors` ThemeExtension. Generated l10n is not committed. | Best-practice baseline the owner asked for. |
| 2026-10-18 | **Responsive, not scaled:** design values in dp, widths flex, fonts never scale with screen size. | The test phone is 360 dp wide versus a 414 dp design; scaling everything would hurt accessibility and tablets. |
| 2026-10-18 | Plan defaults, until the owner overrides them: Firebase + RevenueCat, Riverpod + go_router, Android + iOS. | Needed to plan the 30 steps. The owner can change them before the step that uses them. |

## Gotchas and lessons

- `flutter analyze`, `flutter run` and `flutter test` run `pub get` automatically. That rewrites `pubspec.lock` to the SDK-pinned versions of the local Flutter install. Expect lockfile churn when the machine's Flutter version changes.
- The splash screen will use a timer. Widget tests that pump `App` must advance time (`tester.pump(duration)`) or override the providers.
- `Color.red`, `.green`, `.blue`, `.value` and `.withOpacity()` are deprecated on this SDK. Use `.r`, `.g`, `.b` (0–1), `.toARGB32()` and `.withValues(alpha: …)`.
- **Figma API budget is tiny.** The owner's Figma team is on the free Starter plan, so Tier 1 REST calls (GET file, GET images) are capped at roughly 6–20 per month. Always work from the cache in `docs/figma/raw/` (made by `tool/figma/figma_pull.py`). Batch any new render into one call, and never `--force` without a reason.
- The Figma token has only the `file_content:read` scope. It can't list team files or call `/v1/me`; it needs a file link. The token is **not** stored in the repo. To pull again, the owner sets `FIGMA_TOKEN` in `~/.zshrc`. API calls used so far: 2 Tier 1 + 1 Tier 2, all on 2026-10-18.
- **The design contains placeholder copy.** Don't copy it as-is: lorem ipsum on the New Habit card and the Congratulation popup, "6-month plan for 39.99 usd" under every price, "Goggle Play", "TUE 18" twice in the week strip, and "habits makes us". Prices must come from the store.
- Each screen's `spec.txt` gives exact positions, sizes, colors and fonts, so build from the spec and use `main.png` only for a visual check. Positions are absolute, so turn them into Flutter layout (padding, rows and columns), not `Positioned` everywhere.
- Line endings: `.gitattributes` forces LF (fixed in step 2). Files created on Windows can come back with CRLF; `git ls-files --eol | grep w/crlf` finds them.

## Session log

One line per session: date, what was done, where it stopped.

- **2026-10-18:** Audited the whole project and created the `docs/` folder (this file, plan, current state, screens tracker, design system, architecture, known issues). No app code changed. Waiting for the Figma connection.
- **2026-10-18:** Added the design-sharing guide (`docs/figma/README.md`: MCP, REST token or manual), the per-screen notes template, and a `BACKEND_SPEC.md` seeded from the existing screens. Waiting for the owner to choose a sharing option.
- **2026-10-18:** Pulled the whole Figma file (20 screens: PNG + spec, tokens, image fills). Reviewed every screen. Rewrote SCREENS, DESIGN_SYSTEM and BACKEND_SPEC from the real design. **Stopped at:** ready for the planning and rules session with the owner (agenda in PLAN.md). Owner questions Q1–Q17 are in BACKEND_SPEC §6. No app code changed yet.
- **2026-10-18:** Step 1: committed the baseline, added Fredoka (Klasik stand-in), wrote the 30-step PLAN and RULES. PR, merge, device run. **Next:** Step 2 (project hygiene), after the owner's "go".
- **2026-10-18:** Step 2: foundation and design system (clean slate, strict lints, Riverpod, go_router, l10n, Figma theme tokens, design-system preview page, tests). Plan reshaped to UI-first (28 steps). **Next:** Step 3, splash and onboarding, after the owner's "go".
