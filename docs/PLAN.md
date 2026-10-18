# Build Plan — Step by Step

_Last updated: 2026-10-18 · **Progress: 1 / 30 steps** · Current: waiting for the owner's "go" for Step 2_

Goal: the full Monumental Habits app in Flutter, matching the Figma design ([SCREENS.md](SCREENS.md)), with a real backend ([BACKEND_SPEC.md](BACKEND_SPEC.md)).

**How each step runs:** see [RULES.md §1](RULES.md#1-step-workflow): branch → build → ✅ here → PR → self-review → merge → run on device → wait for "go".

Legend: ✅ done · ⬜ to do · ⚠️ needs an owner decision or account access before it can start.

**Defaults** (the owner can change these any time): Firebase + RevenueCat backend, Riverpod + go_router, Android + iOS. The owner's questions Q1–Q17 are in [BACKEND_SPEC.md §6](BACKEND_SPEC.md#6-open-questions-for-the-owner).

---

## Phase A — Foundation

### ✅ Step 1 — Baseline, docs, design pull, heading font, plan and rules
- Commit the existing work (login and sign-up UI, assets, CocoaPods setup) as a baseline
- `docs/` (memory, plan, rules, screens, design system, backend spec, issues), `tool/figma/figma_pull.py`, `CLAUDE.md`
- Heading font: **Fredoka SemiBold** (OFL), the closest free match to Klasik, registered in `pubspec.yaml`

### ⬜ Step 2 — Project hygiene
- `.gitattributes` (LF) and renormalize line endings; delete `pglite-debug.log`
- Replace the failing counter test with an app smoke test
- Fix the common code: `toHex()`, `withOpacity` → `withValues`, `pop()`, unused fields, `print`
- Update `intl`; remove unused dependencies

### ⬜ Step 3 — Design tokens and theme
- `AppColors` (Figma palette), `AppTextStyles` (Fredoka display + Manrope 500/700 scale), radii, shadows, spacing
- `ThemeData` built from the tokens; old `AppColor` usages replaced

### ⬜ Step 4 — Shared widgets I (forms and buttons)
- PrimaryButton, SecondaryButton, SocialButton, AppTextField (icon and divider, show/hide password, focus and typed styles), AppCheckbox, HeaderIconButton
- A debug-only **widget gallery** screen for checking them on the device

### ⬜ Step 5 — App architecture
- Riverpod + go_router, the `lib/features/...` structure, existing screens moved into it
- Remember that onboarding has been seen (shared_preferences), plus route redirects

## Phase B — Onboarding and auth UI (no backend yet)

### ⬜ Step 6 — Splash and onboarding (screens 1–5)
- Built to the specs; optimized illustration exports; same subtitle with orange highlights; dots; Get Started

### ⬜ Step 7 — Login, Sign Up, Reset Password UI (screens 6–8)
- Built to the specs; validation, loading and error states; a fake auth service behind an interface (swapped for the real one in step 9)

## Phase C — Backend and real authentication

### ⬜ Step 8 — Firebase setup ⚠️
- Owner confirms Firebase, plus the **final app name and bundle IDs**
- Owner creates or approves the Firebase project; `flutterfire configure` for Android and iOS; decide how config files are handled (the repo is public)

### ⬜ Step 9 — Email authentication
- Sign up, log in, reset email, routing by auth state, sign out; Firestore `users/{uid}` (name, marketingOptIn)

### ⬜ Step 10 — Google and Apple sign-in ⚠️
- Needs: Android SHA-1 in Firebase; Apple Developer account and the Sign in with Apple capability

### ⬜ Step 11 — Facebook sign-in ⚠️
- Needs: a Facebook developer app (App ID and secret) from the owner

## Phase D — Habit tracking (core)

### ⬜ Step 12 — App shell
- Bottom nav (illustrated tabs, curved notch, center FAB), side menu, placeholder tabs

### ⬜ Step 13 — Habit data layer ⚠️ (Q1)
- Habit and HabitEntry models, Firestore repository with offline persistence, streak and completion-rate logic with unit tests

### ⬜ Step 14 — Home (screen 9)
- Quote card, week strip, habit grid with cell states, empty state, marking from the grid

### ⬜ Step 15 — New and Edit Habit (screen 10) ⚠️ (Q4, Q5, Q6)
- Name, icon picker, color, frequency (daily or custom days), notification toggle, delete, free-plan limit hook

### ⬜ Step 16 — Reminders (screens 11–12)
- Reminder tiles sheet, time picker sheet, local notifications on due days, permission prompts

### ⬜ Step 17 — Habit detail and analytics (screen 13) ⚠️ (Q2)
- Month calendar, streaks and completion rate, mark complete or missed, easiness rating

### ⬜ Step 18 — Congratulation popup (screen 14) ⚠️ (Q12)
- The dialog, plus milestone triggers

## Phase E — Profile, settings, premium

### ⬜ Step 19 — Profile (screen 18) ⚠️ (Q3)
- Period selector, stats, daily progress rings, longest streak; edit profile and avatar picker

### ⬜ Step 20 — Settings (screen 19) and its subpages
- Notifications, customization, contact and feedback, privacy policy, about (licenses, including OFL), sign out, **delete account**

### ⬜ Step 21 — Premium (screen 20) ⚠️ (Q13, Q14, store products)
- RevenueCat, paywall UI, intro offer countdown, restore purchases, premium gating (habit limit, courses, avatars)

## Phase F — Courses and community

### ⬜ Step 22 — Courses list (screen 15) ⚠️ (Q8)
- Content model and seed data, sort, filter, search, bookmarks and saved list

### ⬜ Step 23 — Course detail and lesson player (screen 16) ⚠️ (Q9, video hosting)
- Video playback, lesson list, locks that lead to the paywall

### ⬜ Step 24 — Community feed (screen 17) ⚠️ (Q10)
- Posts, likes, share, relative times ("41m ago"), create post

### ⬜ Step 25 — Comments and moderation
- Comment threads, report button, counters kept by Cloud Functions

## Phase G — Quality and release

### ⬜ Step 26 — States and polish
- Loading, error and offline states; transitions; accessibility; small-screen fixes

### ⬜ Step 27 — Tests and CI
- Widget and integration tests for the key flows; GitHub Actions running analyze and test

### ⬜ Step 28 — App identity
- Launcher icons, native splash, the app name everywhere

### ⬜ Step 29 — Release preparation ⚠️
- Signing (Android keystore, iOS certificates), store listings, privacy policy, data-safety forms

### ⬜ Step 30 — Release candidate
- Release builds on the device, final QA pass, store submission
