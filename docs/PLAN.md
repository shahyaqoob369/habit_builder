# Build Plan — Step by Step

_Last updated: 2026-10-19 · **Progress: 9 / 28 steps** · Current: Step 10_

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

### ⬜ Step 10 — Community (screen 17)
- Feed with post cards, likes, share, post detail with comments, create post

### ⬜ Step 11 — Profile and settings (screens 18–19)
- Profile stats, progress rings, edit profile, avatar picker; settings and its subpages

### ⬜ Step 12 — Premium paywall (screen 20)
- Offer countdown, benefits, plan cards, subscribe and restore (UI only)

## Phase C — Backend and integration

### ⬜ Step 13 — Firebase setup ⚠️
- Owner confirms Firebase, plus the **final app name and bundle IDs**; owner creates or approves the project; `flutterfire configure`; decide how config files are handled (public repo)

### ⬜ Step 14 — Email authentication
- Sign up, log in, reset email, routing by auth state, sign out, Firestore `users/{uid}`

### ⬜ Step 15 — Google and Apple sign-in ⚠️
- Android SHA-1 in Firebase; Apple Developer account with the Sign in with Apple capability

### ⬜ Step 16 — Facebook sign-in ⚠️
- A Facebook developer app (App ID and secret) from the owner

### ⬜ Step 17 — Habit data layer ⚠️ (Q1, Q2)
- Models, Firestore repository with offline persistence, streak and completion-rate logic with unit tests

### ⬜ Step 18 — Connect the habit screens to real data ⚠️ (Q4–Q6, Q12)
- Home, New and Edit Habit, Habit detail, congratulation triggers, free-plan habit limit

### ⬜ Step 19 — Reminder notifications
- Local notifications on due days, permission prompts, rescheduling

### ⬜ Step 20 — Profile and settings, real data ⚠️ (Q3)
- Stats, edit profile, feedback, sign out, **delete account**

### ⬜ Step 21 — Premium with RevenueCat ⚠️ (Q13, Q14, store products)
- Plans, intro offer, restore, gating (habits, courses, avatars)

### ⬜ Step 22 — Courses backend and video ⚠️ (Q8, Q9, hosting)
- Content model and seed data, video playback, locks

### ⬜ Step 23 — Community backend ⚠️ (Q10)
- Posts, likes, comments, reporting, counters kept by Cloud Functions

## Phase D — Quality and release

### ⬜ Step 24 — States and polish
- Loading, error and offline states; transitions; accessibility; small-screen fixes

### ⬜ Step 25 — Tests and CI
- Widget and integration tests for the key flows; GitHub Actions running analyze and test

### ⬜ Step 26 — App identity
- Launcher icons, native splash, the app name everywhere

### ⬜ Step 27 — Release preparation ⚠️
- Signing (Android keystore, iOS certificates), store listings, privacy policy, data-safety forms

### ⬜ Step 28 — Release candidate
- Release builds on the device, final QA pass, store submission
