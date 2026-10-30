# Project Memory

The project's long-term memory. Read it at the start of every session and update it whenever something is decided or learned. Keep entries short, and keep facts that will still be true next month. Short-lived status goes in [PLAN.md](PLAN.md) or [SCREENS.md](SCREENS.md).

_Last updated: 2026-10-20_

---

## Project identity

- **Product name (in UI):** Monumental Habits. Splash and onboarding say "WELCOME TO MONUMENTAL HABITS".
- **App name (home screen):** "Monumental Habits" (iOS `CFBundleDisplayName`, Android `android:label`); the short iOS `CFBundleName` is "Monumental".
- **App icon:** a stand-in until the owner has one (the kit has none): `python3 tool/figma/build_app_icon.py` makes `assets/app_icon/` from the teepee, which also writes the iOS icon set (light, dark, tinted), then `dart run flutter_launcher_icons` for Android (config in `pubspec.yaml`).
- **Package name:** `habit_builder`. Bundle and application ID (owner, 2026-10-20): `com.luminalabs.monumentalhabits` on iOS and Android. It can't change after the store release.
- **Firebase:** project ID in the local `.firebaserc` (not in the repo: it's public). Config files are gitignored (public repo); regenerate them with `flutterfire configure` ([FIREBASE.md](FIREBASE.md)). Analytics: every event is an `AnalyticsEvent` factory, and `analyticsProvider` defaults to `RecordingAnalytics` (main overrides it with Firebase), so tests never touch Firebase. The simulator debug flag is `-FIRAnalyticsDebugEnabled` (not `-FIRDebugEnabled`). Integration tests: `find.text` also matches a text field showing that text, so scope it (`find.descendant(of: HomePage…)`). Text fields contain their own `Scrollable`, so `scrollUntilVisible` needs `scrollable:` or use `ensureVisible`. Wait with a `pumpUntil` loop (network isn't an animation), then `pumpAndSettle` after navigation, or both routes match. `cloud_firestore` exports a class named `Type`, so don't use `Type` as a parameter type in files that import it. `MessageView` upper-cases titles. iOS silently drops local notifications scheduled without permission (`pendingNotificationRequests` comes back empty); in integration tests, grant provisional permission with `requestPermissions(alert: true, sound: true, provisional: true)` after the plugin is initialized. New collection-group indexes take a few minutes to build after `firebase deploy`; until then those queries fail (a first test run failed that way). Timezone tests: call `tz_data.initializeTimeZones()` at the top of `main()`, not in `setUpAll` (group bodies run first). Platform services follow the same pattern as repositories: the provider defaults to a recording fake, and `main` overrides it (`reminderSchedulerProvider`, `analyticsProvider`). Fake repository streams: `onCancel` must not return the cancel future (`onCancel: () => unawaited(sub.cancel())`). That future completes in the root zone, which widget tests never run, so `stream.first` hangs forever. The Firestore API can't be turned on from the Firebase CLI (`firestore:databases:create` gets 403): use the console's "Create database". Firebase CLI commands need `--non-interactive`, or they hang on first-run prompts. `flutterfire` lives in `~/.pub-cache/bin` (not on PATH). iOS minimum is 15.0 (Firebase SDK).
- **Design source:** the Figma file **"Pixel True – Habit Builder UI Kit"** (key `4i8xPGsRhPXs1Gs076OpeN`, last edited 2025-05-29). It has 3 pages: Introduction (promo only), **Screens (20 app screens)** and Branding Guideline (one image). It was pulled on 2026-10-18 into `docs/figma/`. See [SCREENS.md](SCREENS.md), [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) and [BACKEND_SPEC.md](BACKEND_SPEC.md).
- **App areas in the design:** onboarding, auth (login, sign up, reset), habit tracking (home grid, new habit, reminders, habit detail and analytics, congratulation), courses (list, detail with video lessons), community feed, profile stats, settings, premium subscription.
- **Goal:** build the full app so that it matches the Figma design.
- **Target: iPhone and the App Store first** (owner, 2026-10-20), Google Play after. Check work on the iOS Simulator (an iPhone 17 Pro, 402 × 874 pt, is usually booted).
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
- **Images:** paths in `AppImages` (`lib/core/assets/app_images.dart`); files are WebP with `2.0x/` and `3.0x/` variants, produced by `tool/figma/build_assets.py` from Figma renders (`figma_pull.py export`, manifest `tool/figma/assets.json`; recipes in `tool/figma/app_assets.json`).
- **Shared widgets** live in `lib/core/widgets/`: PrimaryButton, PageDots, HighlightedText, AppTextField, AppCheckbox, HeaderIconButton, TextLink, AppIcon. Highlighted words in strings use `<h>…</h>` markers.
- **Icons:** single-color SVGs in `assets/icons/` (paths in `AppIcons`, drawn with `AppIcon`, tinted at runtime). Brand logos with Figma shadows are WebP in `assets/img/brand/`. Both come from `tool/figma/build_icons.py` (needs `rsvg-convert`).
- **Auth:** UI talks to the `AuthRepository` interface; `authRepositoryProvider` returns `FakeAuthRepository` until step 15. Each auth screen has its own `AuthFormController` provider (pending method + last failure). Field rules are in `AuthValidators`; messages in `auth_messages.dart`.
- **Shell:** `StatefulShellRoute.indexedStack` with 4 branches (home, courses, community, settings) in `AppShell`; the bar is `AppBottomBar` (Scaffold `extendBody`, so pages draw behind it and get its height as bottom padding). Pages use `AppHeader` (button · centered title · button) and `MenuButton`, which opens the drawer through `AppShellScope`.
- **Icons:** `AppIcon(AppIcons.x, color: …)` for single-color glyphs, `AppIcon.original(...)` for the full-color ones (stat, settings, lesson tiles…); `AppIcons` marks which is which.
- **Simulator shortcut:** debug builds accept `--dart-define=INITIAL_ROUTE=/home` to open any route directly (there is no tap automation for the simulator on this Mac).
- **Routes:** Sign Up and Reset Password are nested under Login (`/login/sign-up`, `/login/reset-password`), so Back and the "Login"/"Sign In" links return to it with `goNamed(AppRoute.login.name)`.
- **Persistence:** `SharedPreferencesWithCache` via `sharedPreferencesProvider` (overridden in `main` and in tests). Every key must be in `PreferenceKeys.all`.

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
| 2026-10-21 | **No Facebook sign-in; Sign in with Apple takes its place** on Login and Sign Up (iOS only for now). Plan step 17 dropped. | Owner: "instead of facebook add app signin". Apple also covers App Store rule 4.8. |
| 2026-10-20 | **Steps run back to back** without a "go" between them, until the owner stops for a review. **iPhone / App Store first**; test on the iOS Simulator. | Owner instructions, 2026-10-20. |
| 2026-10-18 | Plan defaults, until the owner overrides them: Firebase + RevenueCat, Riverpod + go_router, Android + iOS. | Needed to plan the 30 steps. The owner can change them before the step that uses them. |

## Gotchas and lessons

- `flutter analyze`, `flutter run` and `flutter test` run `pub get` automatically. That rewrites `pubspec.lock` to the SDK-pinned versions of the local Flutter install. Expect lockfile churn when the machine's Flutter version changes.
- Widget tests that pump the whole app use `tester.pumpFullApp(prefs)` (zero splash duration). Create prefs with `createTestPreferences()` in `setUp`, or via `tester.runAsync` inside a test.
- **Native splash:** after `dart run flutter_native_splash:create`, re-apply the transparent status bar in `android/app/src/main/res/values{,-night}/styles.xml` (`windowDrawsSystemBarBackgrounds=true`, `statusBarColor` transparent, `windowLightStatusBar`); the generator resets it.
- **Realme C3 quirks:** `pm clear` is blocked (uninstall to reset app data). Cold start of a debug build takes about 8 s; use `flutter build apk --release` for screenshots and pixel checks.
- **Figma export offsets:** a rendered group's PNG can be larger than its render bounds. Find the crop by matching against the screen's `main.png` (done for the splash: crop at (179, 153) px at 3×).
- `Color.red`, `.green`, `.blue`, `.value` and `.withOpacity()` are deprecated on this SDK. Use `.r`, `.g`, `.b` (0–1), `.toARGB32()` and `.withValues(alpha: …)`.
- **Figma API budget is tiny.** The owner's Figma team is on the free Starter plan, so Tier 1 REST calls (GET file, GET images) are capped at roughly 6–20 per month. Always work from the cache in `docs/figma/raw/` (made by `tool/figma/figma_pull.py`). Batch any new render into one call, and never `--force` without a reason.
- The Figma token has only the `file_content:read` scope. It can't list team files or call `/v1/me`; it needs a file link. The token is **not** stored in the repo. To pull again, the owner sets `FIGMA_TOKEN` in `~/.zshrc`. API calls used so far: 6 Tier 1 + 1 Tier 2 (2 on 2026-10-18, 2 on 2026-10-19 for the step 3–4 assets, 2 on 2026-10-20 for **all** remaining screens 9–20). Every asset the design needs is now exported; no more calls should be needed.
- **The design contains placeholder copy.** Don't copy it as-is: lorem ipsum on the New Habit card and the Congratulation popup, "6-month plan for 39.99 usd" under every price, "Goggle Play", "TUE 18" twice in the week strip, and "habits makes us". Prices must come from the store.
- Each screen's `spec.txt` gives exact positions, sizes, colors and fonts, so build from the spec and use `main.png` only for a visual check. Positions are absolute, so turn them into Flutter layout (padding, rows and columns), not `Positioned` everywhere.
- **Material 3 text fields add a hidden 4 pt gap**: without a prefix icon the text starts at contentPadding.start + 4; with one, contentPadding.start is ignored and the text sits 4 pt after the icon. The theme uses 16 pt padding and `AppTextField`'s icon cell is 61 pt wide to land on Figma's 20 / 65 pt.
- **Tests load the real fonts** (`test/flutter_test_config.dart`), so layout tests can assert Figma positions. Use `tester.useScreen(designSize)` and, for a 44 pt status bar, `tester.view.padding = FakeViewPadding(top: 44 * 3)`.
- **Riverpod 3 pauses providers nobody listens to.** In tests, `container.listen(provider, …)` before awaiting `provider.future`, or it never completes.
- **Never `await` a stream or a repository future in a `testWidgets` body before/between pumps**: under the fake clock it can hang for 10 minutes (0 % CPU). Seed fakes synchronously and read state through a `@visibleForTesting` getter (e.g. `FakeHabitRepository.habits`).
- **`pumpAndSettle` never settles on the paywall** (its offer countdown ticks every second): use `pump(const Duration(seconds: 1))` there.
- **No `timeout` command on macOS.** Use `flutter test --timeout 60s` to stop hung tests, and run long suites in the foreground.
- **Checking sheets and dialogs without tapping the simulator:** pump them in a throwaway widget test at `designSize` and write a golden (`--update-goldens`), then compare the PNG with Figma. FontAwesome glyphs show as boxes in tests (font not loaded there).
- **RevenueCat API (v2):** `POST /projects/{id}/apps|products|entitlements|offerings`; Test Store products need `subscription.duration` and prices via `POST /products/{id}/test_store_prices`; attach with `/entitlements/{id}/actions/attach_products` (`product_ids`) and `/packages/{id}/actions/attach_products` (`products` with `eligibility_criteria`); make an offering current with `POST /offerings/{id}` `{is_current: true}`. The Test Store key must only be used in debug builds.
- **Platform in tests:** widget tests default to Android. Login and Sign Up show Apple only on iOS, so their Figma layout tests and the screen audit use `variant: TargetPlatformVariant.only(TargetPlatform.iOS)`.
- **App icon on iOS:** `build_app_icon.py` writes the iOS icon set itself (one 1024 px icon each for light, dark and tinted), and `flutter_launcher_icons` runs for Android only (`ios: false`). Its iOS mode writes legacy sizes without dark or tinted variants (iOS 26 then makes its own, which looks poor), and it breaks `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` in `project.pbxproj`.
- **Debug builds on an iPhone with iOS 26 need the USB cable.** The app stays on the splash until the Mac's debugger (LLDB) attaches: about a minute over USB, 15+ minutes over Wi-Fi (and the connection then drops). It isn't the app or RevenueCat.
- Line endings: `.gitattributes` forces LF (fixed in step 2). Files created on Windows can come back with CRLF; `git ls-files --eol | grep w/crlf` finds them.

## Session log

One line per session: date, what was done, where it stopped.

- **2026-10-18:** Audited the whole project and created the `docs/` folder (this file, plan, current state, screens tracker, design system, architecture, known issues). No app code changed. Waiting for the Figma connection.
- **2026-10-18:** Added the design-sharing guide (`docs/figma/README.md`: MCP, REST token or manual), the per-screen notes template, and a `BACKEND_SPEC.md` seeded from the existing screens. Waiting for the owner to choose a sharing option.
- **2026-10-18:** Pulled the whole Figma file (20 screens: PNG + spec, tokens, image fills). Reviewed every screen. Rewrote SCREENS, DESIGN_SYSTEM and BACKEND_SPEC from the real design. **Stopped at:** ready for the planning and rules session with the owner (agenda in PLAN.md). Owner questions Q1–Q17 are in BACKEND_SPEC §6. No app code changed yet.
- **2026-10-18:** Step 1: committed the baseline, added Fredoka (Klasik stand-in), wrote the 30-step PLAN and RULES. PR, merge, device run. **Next:** Step 2 (project hygiene), after the owner's "go".
- **2026-10-18:** Step 2: foundation and design system (clean slate, strict lints, Riverpod, go_router, l10n, Figma theme tokens, design-system preview page, tests). Plan reshaped to UI-first (28 steps). **Next:** Step 3, splash and onboarding, after the owner's "go".
- **2026-10-19:** Step 3: splash and onboarding rebuilt pixel-perfect (Figma asset export, WebP 1×/2×/3× pipeline, native splash refreshed, PrimaryButton, PageDots, HighlightedText, onboarding-seen flag, 25 tests). Assets for step 4 (auth) are already exported locally. **Next:** Step 4, after the owner's "go".
- **2026-10-19:** Step 4: Login, Sign Up and Reset Password pixel-matched (icon pipeline, AppTextField, SocialButton, AppCheckbox, HeaderIconButton, TextLink, fake `AuthRepository` with a demo account, real fonts in tests, 76 tests). **Next:** Step 5, app shell, after the owner's "go".
- **2026-10-20:** Owner: run steps back to back; iPhone first, test on the simulator. Exported every remaining Figma asset (2 calls). Step 5: app shell (bottom bar with notch and FAB, drawer, 4 tab branches, AppHeader, INITIAL_ROUTE). **Next:** Step 6 (Home).
- **2026-10-20:** Steps 6–12 back to back: Home, New/Edit Habit + reminder sheets, habit detail + congratulation, Courses, Community (report/hide), Profile + Settings (delete account), Premium paywall. **All 20 Figma screens are built (UI phase B done)**, on sample data behind repository interfaces; 168 tests. **Next:** Step 13 Firebase — needs the owner (Firebase access, final app name, bundle IDs).
- **2026-10-20:** Step 13: Firebase project created from the owner's CLI login; app name Monumental Habits, bundle ID `com.luminalabs.monumentalhabits`; iOS + Android registered, `firebase_core` initialized, config gitignored. Owner added Google Analytics to the plan (new step 14; later steps renumbered, now 29). **Next:** Step 14, needs the owner to link Google Analytics in the console.
- **2026-10-20:** Step 14: Google Analytics (owner linked it in the console): `Analytics` interface + Firebase implementation, router screen views, event catalog, no IDFA / AD_ID, Share usage data switch, 172 tests. The project ID was removed from the public docs (local `.firebaserc` only). **Next:** Step 15, email authentication.
- **2026-10-20:** Step 15: Firebase email auth (owner enabled Email/Password and created Firestore `nam5` in the console), auth-guarded router, `users/{uid}` + rules deployed, password-confirmed deletion, `FAKE_AUTH` debug flag; integration test green on the simulator against the real project; 178 unit/widget tests. **Next:** Step 16, needs the Apple Developer account.
- **2026-10-20:** Step 18 (ahead of 16–17, which wait for the owner): Firestore habits (`HabitMapper`, offline-first `FirestoreHabitRepository`, per-user override in `main`), rules, habits deleted with the account; both integration tests green; 183 tests. `fake_cloud_firestore` doesn't support cloud_firestore 7, so repositories are tested with integration tests on the simulator. **Next:** Step 19.
- **2026-10-20:** Step 19: free-plan limit of 3 habits (paywall), `firebase_backend.dart`, background profile writes, full-UI integration test against Firebase (found and fixed a test-timing issue: sign-up finishes about 5 s after Home appears on a slow network). Cleaned 2 leftover test accounts. **Next:** Step 20 (reminders).
- **2026-10-20:** Step 20: reminder notifications (plan, sync, permission prompts, resync on resume because iOS drops reminders scheduled without permission). Unit tests plus `reminders_test.dart` on the simulator. The first iOS build with the new pods took about 40 min on a loaded Mac. **Next:** Step 21 (feedback to Firestore).
- **2026-10-20:** Step 21: feedback saved to Firestore under the user, rules deployed, deleted with the account. Profile and settings were already live from steps 15–19. **Next:** Step 22 (RevenueCat), which needs the owner's App Store Connect and RevenueCat accounts.
- **2026-10-21:** Owner reviewed and said continue. Step 24: community on Firestore (rules-kept counters, no Cloud Functions), delete own post, account cleanup; two-user integration test green; all 4 end-to-end tests green; removed 1 leftover test account (the owner's own account kept). **Next:** Step 25 (states and polish). Steps 16, 17, 22 and 23 wait for the owner.
- **2026-10-21:** Step 25: screen audit test (17 screens, small phone at 200 % text, tap targets, labels), day chip fix, offline banner. The text contrast question is left to the owner. **Next:** Step 26 (tests and CI).
- **2026-10-21:** Step 26: GitHub Actions CI (format, analyze, test) with a placeholder Firebase options file, so no secrets go to GitHub; checked on a clean copy without the real config. **Next:** Step 27 (app identity).
- **2026-10-21:** Step 27: stand-in launcher icon (the kit's teepee, iOS + Android adaptive), short iOS bundle name, web titles; the native splash was already done in step 3. The real icon is an owner decision. **Next:** Step 28 (release preparation), which needs the owner (Apple Developer account, privacy policy, support email).
- **2026-10-21:** Owner enabled Google and Apple sign-in and gave the Apple team ID; asked to replace Facebook with Apple and to test on their iPhone 13 Pro Max. Step 16: Google + Apple on iOS (new users logged as `sign_up`, re-sign-in to delete, Apple token revocation), Facebook removed, signing team and entitlement set; layout tests and the screen audit now run as iOS. **Next:** the owner tests on the iPhone; then step 28 (needs the owner).
- **2026-10-30:** Owner gave a RevenueCat API key (to be rotated after step 22). Step 22 (part 1): RevenueCat project configured through the API v2 (iOS app, Test Store, products `premium_monthly`/`premium_yearly`/`premium_lifetime`, entitlement `premium`, offering `default` with metadata), `RevenueCatPremiumRepository`, Test Store in debug builds, SDK keys gitignored with a CI stub. **Next:** App Store Connect steps (owner), then sandbox purchases.
- **2026-10-30:** Owner tested Premium on the iPhone 13 Pro Max (Test Store over USB): plans, purchase and restore work. PR #25 merged; step 22 stays 🟡 until the App Store Connect steps. **Next:** owner's App Store Connect steps and pricing.
