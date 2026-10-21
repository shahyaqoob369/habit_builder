# Build Plan — Step by Step

_Last updated: 2026-10-21 · **Progress: 25 / 29 steps** · Current: Step 28 (release preparation, needs the owner). Waiting for the owner: 22 (RevenueCat, App Store Connect), 23 (course content and video hosting), 28 (support email, privacy policy and terms links, Apple sign-in key)._

Goal: the full Monumental Habits app in Flutter, matching the Figma design pixel for pixel ([SCREENS.md](SCREENS.md)), built with best practices ([ARCHITECTURE.md](ARCHITECTURE.md)), with a real backend ([BACKEND_SPEC.md](BACKEND_SPEC.md)).

**Approach (owner, 2026-10-18):** rebuild the UI **from scratch**, including the screens that already existed. **UI first** with sample data, so every screen can be checked on the device early; then connect the backend.

**How each step runs:** see [RULES.md §1](RULES.md#1-step-workflow): branch → build → ✅ here → PR → self-review → merge → check on the iOS Simulator → next step (since 2026-10-20 the steps run back to back until the owner stops for a review).

Legend: ✅ done · ⬜ to do · ⚠️ needs an owner decision or account access before it can start.

**Defaults** (the owner can change these any time): Firebase + RevenueCat, Riverpod + go_router, Android + iOS. Owner questions Q1–Q17 are in [BACKEND_SPEC.md §6](BACKEND_SPEC.md#6-open-questions-for-the-owner).

---

## Phase A — Foundation

### ✅ Step 1 — Baseline, docs, design pull, heading font, plan and rules
- Committed the earlier work, all docs, `tool/figma/figma_pull.py`, and Fredoka SemiBold (the free stand-in for Klasik)

### ✅ Step 2 — Foundation and design system
- Clean slate: removed the old UI code, unused assets, unused Manrope weights and unused packages
- Strict lints (`very_good_analysis`), LF line endings (`.gitattributes`)
- Architecture: feature-first folders, Riverpod, go_router, localization files (`gen-l10n`)
- Theme from Figma: `AppColors` (ThemeExtension), `AppTextStyles` (Fredoka display + Manrope), spacing, radii, shadows
- Design-system preview page (temporary home), tests

## Phase B — UI, pixel perfect (sample data, no backend)

### ✅ Step 3 — Splash and onboarding (screens 1–5)
- Asset pipeline (optimized exports at 1×/2×/3×), PrimaryButton, page dots, onboarding flow
- Visual check: device screenshots compared side by side with the Figma renders

### ✅ Step 4 — Login, Sign Up, Reset Password (screens 6–8)
- AppTextField, SocialButton, AppCheckbox, HeaderIconButton, TextLink; validation, loading and error states; a fake auth service behind an interface (`AuthRepository`, demo account `demo@example.com` / `habits123`)

### ✅ Step 5 — App shell
- Bottom nav (illustrated tabs, curved notch, center FAB), side menu (not in the design, built in its style), tab routes
- One Figma export (2 API calls) for every icon and illustration of screens 9–20

### ✅ Step 6 — Home (screen 9)
- Quote card, week strip, habit grid with Full/Half cells, empty state, sample habits

### ✅ Step 7 — New and Edit Habit with reminders (screens 10–12)
- Name, icon picker, color, frequency, notification toggle; reminder tiles sheet; time picker sheet

### ✅ Step 8 — Habit detail and congratulation popup (screens 13–14)
- Month calendar, stat tiles, mark complete or missed, easiness rating sheet, congratulation dialog

### ✅ Step 9 — Courses (screens 15–16)
- Courses list (banner, sort, filters, search, bookmark), course detail (video header, lesson list, locks)

### ✅ Step 10 — Community (screen 17)
- Feed with post cards, likes, share, post detail with comments, create post

### ✅ Step 11 — Profile and settings (screens 18–19)
- Profile stats, progress rings, edit profile, avatar picker; settings and its subpages

### ✅ Step 12 — Premium paywall (screen 20)
- Offer countdown, benefits, plan cards, subscribe and restore (UI only)

## Phase C — Backend and integration

### ✅ Step 13 — Firebase setup
- Firebase project "Monumental Habits" (created with the owner's Firebase CLI login); app name **Monumental Habits**; bundle and application ID `com.luminalabs.monumentalhabits`
- iOS and Android apps registered with `flutterfire configure`; `firebase_core` starts in `main.dart`; iOS minimum raised to 15.0
- Config files stay local-only (owner decision, public repo): see [FIREBASE.md](FIREBASE.md)

### ✅ Step 14 — Google Analytics
- Owner linked Google Analytics in the Firebase console (one stream per app)
- `firebase_analytics` behind an `Analytics` interface (`RecordingAnalytics` in tests); a screen view for every route change; the event catalog in `AnalyticsEvent` (onboarding, sign up, log in, habit created / deleted / completed / missed / rated, streak milestone, course and lesson opened, post created and shared, paywall shown, purchase, restore)
- Privacy: no advertising ID on iOS (pods without IDFA) or Android (AD_ID permission removed), so no tracking prompt; a "Share usage data" switch in More customization; no names, emails or post text in events
- Checked on the iOS Simulator: the SDK starts without IDFA and uploads events; see DebugView in [FIREBASE.md](FIREBASE.md#analytics)

### ✅ Step 15 — Email authentication
- `FirebaseAuthRepository`: sign up, log in, reset email (doesn't reveal accounts), sign out, rename, delete account (password confirmed)
- Routing by auth state (router redirect + session restored on the splash); "Keep me signed in"
- Firestore `users/{uid}` profile (database `nam5`), `firestore.rules`: own profile only, everything else denied
- `integration_test/auth_flow_test.dart` passes against the real project on the iOS Simulator

### ✅ Step 16 — Google and Apple sign-in
- Android SHA-1 in Firebase; Apple Developer account with the Sign in with Apple capability
- Done (iOS): Google (`google_sign_in`) and Apple (Firebase's native Apple flow) on Login and Sign Up; a new account is logged as `sign_up`, and its profile is created. Deleting a Google or Apple account confirms by signing in again, and Apple's token is revoked. Signing uses the owner's team; Sign in with Apple entitlement. Android (SHA-1, Apple's web flow) comes with the Android release.

### ✅ Step 17 — ~~Facebook sign-in~~ dropped
- Owner, 2026-10-21: no Facebook; **Sign in with Apple takes its place** in the design (step 16). The Facebook code, logo and color token were removed.

### ✅ Step 18 — Habit data layer (done before 16–17, which wait for the owner)
- `FirestoreHabitRepository` at `users/{uid}/habits` (days kept in the habit document), offline-first writes; `HabitMapper` with unit tests; per-user repository wired in `main`, so the screens already use real data
- Rules validate habit fields; deleting the account deletes the habits
- `integration_test/habits_flow_test.dart` passes against the real project

### ✅ Step 19 — Connect the habit screens to real data
- The screens run on Firestore (since step 18); Firebase wiring in `lib/app/firebase_backend.dart`, shared by `main` and the integration tests
- Free plan: 3 habits (Q13 default); the + button and "Create New Habit" open the paywall with a note at the limit
- Profile saves no longer wait for the server (sign up finishes faster, works like habits)
- `integration_test/app_flow_test.dart` drives the real UI against Firebase: sign up → empty Home → add habit → complete → Firestore + analytics checked → delete account

### ✅ Step 20 — Reminder notifications
- Local notifications (flutter_local_notifications, device time zone): an every-day habit gets one daily reminder per time, other habits a weekly one per due day; at most 64 (the iOS limit)
- `reminderSyncProvider` keeps them in step with the habits, the Settings switch and sign-out; marking days doesn't reschedule; schedules again when the app comes back (permission may have been granted in Settings); tapping a reminder opens the habit
- Permission is asked when a reminder is first turned on (New Habit toggle, Settings switch); a refusal explains where to turn it on and opens Settings
- `integration_test/reminders_test.dart` checks the real iOS pending notifications

### ✅ Step 21 — Profile and settings, real data
- Stats come from the Firestore habits; rename, sign out and delete account go through Firebase (steps 15–19)
- Feedback is saved at `users/{uid}/feedback` (message, time, platform, app version) and deleted with the account; rules validate it
- Settings stay on the device (`SharedPreferences`)

### ⬜ Step 22 — Premium with RevenueCat ⚠️ (Q13, Q14, store products)
- Plans, intro offer, restore, gating (habits, courses, avatars)

### ⬜ Step 23 — Courses backend and video ⚠️ (Q8, Q9, hosting)
- Content model and seed data, video playback, locks

### ✅ Step 24 — Community backend (Q10 defaults)
- `FirestoreCommunityRepository`: feed (newest 100), likes, comments (loaded per post), report, block, delete own post
- Counters kept by the security rules (each like or comment moves its post's counter by exactly one in the same batch), so no Cloud Functions or Blaze plan; collection-group indexes deployed
- Deleting an account removes the user's posts, comments, likes and blocks
- `integration_test/community_flow_test.dart`: two users, tampering refused, cleanup verified against the real project

## Phase D — Quality and release

### ✅ Step 25 — States and polish
- `test/app/screens_audit_test.dart` opens all 17 screens: each fits a small phone (375 × 667) at 200 % text, and passes the iOS tap-target and labelled-button checks
- Fixed: the Home day chips overflowed at very large text (they shrink to fit now)
- Offline banner (`connectivity_plus`): "You’re offline. Your habits are saved and will sync…" while there's no connection
- Loading and error views were already on every data screen (steps 6–12); text contrast left to the owner (see KNOWN_ISSUES)

### ✅ Step 26 — Tests and CI
- Widget and integration tests for the key flows; GitHub Actions running analyze and test
- Done: `.github/workflows/ci.yml` (format, analyze, 234 unit/widget tests) on each PR and on `main`, with the placeholder `tool/ci/firebase_options_stub.dart` instead of the real config, so no secrets are needed. The 5 end-to-end tests (`integration_test/`) need the real Firebase project and run on the dev Mac's simulator.

### ✅ Step 27 — App identity
- Launcher icons, native splash, the app name everywhere
- Done: the Figma kit has no app icon, so the launcher icon is a stand-in (the kit's teepee on cream, iOS and Android adaptive) until the owner has one (KNOWN_ISSUES). The native splash matches Figma since step 3. The name is "Monumental Habits" on iOS, Android and the web (short iOS bundle name "Monumental").

### ⬜ Step 28 — Release preparation ⚠️
- Signing (Android keystore, iOS certificates), store listings, privacy policy, data-safety forms

### ⬜ Step 29 — Release candidate
- Release builds on the device, final QA pass, store submission
