# Screen Tracker

The 20 Figma screens, with their code status. Pulled 2026-10-18 from **Pixel True – Habit Builder UI Kit**. Images and exact specs are in [figma/index.md](figma/index.md). The `png` and `spec` links below are **local-only** (not on GitHub; see [figma/README.md](figma/README.md)).

**Status:** ⬜ Not started · 🟦 In progress · ✅ Matches Figma (checked on the device)

The UI is rebuilt from scratch (owner decision, 2026-10-18). Screens 1–7 were built before the design and were removed in step 2; they return in plan steps 3–4.

## Screens in the design

| # | Figma screen | Flow | Code | Status | Design files |
|---|---|---|---|---|---|
| 1 | Splash Screen | Onboarding | [splash_page.dart](../lib/features/splash/presentation/splash_page.dart) | ✅ | [png](figma/screens/01-splash-screen/main.png) · [spec](figma/screens/01-splash-screen/spec.txt) |
| 2 | Introduction 1 | Onboarding | [onboarding_page.dart](../lib/features/onboarding/presentation/onboarding_page.dart) | ✅ | [png](figma/screens/02-introduction-1/main.png) · [spec](figma/screens/02-introduction-1/spec.txt) |
| 3 | Introduction 2 | Onboarding | [onboarding_page.dart](../lib/features/onboarding/presentation/onboarding_page.dart) | ✅ | [png](figma/screens/03-introduction-2/main.png) · [spec](figma/screens/03-introduction-2/spec.txt) |
| 4 | Introduction 3 | Onboarding | [onboarding_page.dart](../lib/features/onboarding/presentation/onboarding_page.dart) | ✅ | [png](figma/screens/04-introduction-3/main.png) · [spec](figma/screens/04-introduction-3/spec.txt) |
| 5 | Introduction 4 | Onboarding | [onboarding_page.dart](../lib/features/onboarding/presentation/onboarding_page.dart) | ✅ | [png](figma/screens/05-introduction-4/main.png) · [spec](figma/screens/05-introduction-4/spec.txt) |
| 6 | Login Page | Auth | [login_page.dart](../lib/features/auth/presentation/login_page.dart) | ✅ | [png](figma/screens/06-login-page/main.png) · [spec](figma/screens/06-login-page/spec.txt) |
| 7 | Sign Up page | Auth | [sign_up_page.dart](../lib/features/auth/presentation/sign_up_page.dart) | ✅ | [png](figma/screens/07-sign-up-page/main.png) · [spec](figma/screens/07-sign-up-page/spec.txt) |
| 8 | Reset Password | Auth | [reset_password_page.dart](../lib/features/auth/presentation/reset_password_page.dart) | ✅ | [png](figma/screens/08-reset-password/main.png) · [spec](figma/screens/08-reset-password/spec.txt) |
| 9 | Homepage – Tracking Habits | Home | [home_page.dart](../lib/features/home/presentation/home_page.dart) | ✅ | [png](figma/screens/09-homepage-tracking-habits/main.png) · [spec](figma/screens/09-homepage-tracking-habits/spec.txt) |
| 10 | Homepage – New Habit | Habits | [new_habit_page.dart](../lib/features/habits/presentation/new_habit_page.dart) | ✅ | [png](figma/screens/10-homepage-new-habit/main.png) · [spec](figma/screens/10-homepage-new-habit/spec.txt) |
| 11 | New Habit – Reminder (bottom sheet) | Habits | [reminders_sheet.dart](../lib/features/habits/presentation/sheets/reminders_sheet.dart) | ✅ | [png](figma/screens/11-homepage-new-habit-reminder/main.png) · [spec](figma/screens/11-homepage-new-habit-reminder/spec.txt) |
| 12 | New Habit – Set Time (bottom sheet) | Habits | [time_picker_sheet.dart](../lib/features/habits/presentation/sheets/time_picker_sheet.dart) | ✅ | [png](figma/screens/12-homepage-set-time/main.png) · [spec](figma/screens/12-homepage-set-time/spec.txt) |
| 13 | Analytics (habit detail, 414×1332, scrolls) | Habits | [habit_detail_page.dart](../lib/features/habits/presentation/habit_detail_page.dart) | ✅ | [png](figma/screens/13-analytics/main.png) · [spec](figma/screens/13-analytics/spec.txt) |
| 14 | Congratulation Popup (dialog) | Habits | [congratulation_dialog.dart](../lib/features/habits/presentation/congratulation_dialog.dart) | ✅ | [png](figma/screens/14-congratulation-popup/main.png) · [spec](figma/screens/14-congratulation-popup/spec.txt) |
| 15 | Course overview (courses list) | Courses | — | ⬜ | [png](figma/screens/15-course-overview/main.png) · [spec](figma/screens/15-course-overview/spec.txt) |
| 16 | Course – what's inside (course detail) | Courses | — | ⬜ | [png](figma/screens/16-course-what-s-inside/main.png) · [spec](figma/screens/16-course-what-s-inside/spec.txt) |
| 17 | Community Page | Community | — | ⬜ | [png](figma/screens/17-community-page/main.png) · [spec](figma/screens/17-community-page/spec.txt) |
| 18 | Profile Dashboard | Profile | — | ⬜ | [png](figma/screens/18-profile-dashboard/main.png) · [spec](figma/screens/18-profile-dashboard/spec.txt) |
| 19 | Settings | Settings | — | ⬜ | [png](figma/screens/19-settings/main.png) · [spec](figma/screens/19-settings/spec.txt) |
| 20 | Subscription Page ("Premium") | Premium | — | ⬜ | [png](figma/screens/20-subscription-page/main.png) · [spec](figma/screens/20-subscription-page/spec.txt) |

## Navigation map (inferred from the design)

```
Splash ─▶ Intro 1 ─▶ 2 ─▶ 3 ─▶ 4 ─(Get Started / Skip)─▶ Login ─▶ Sign Up | Reset Password (both return to Login)
                                                         │
                                       (signed in) ──────┴─▶ Home
Bottom nav (Home, Courses, Community, Settings):  [Home] [Courses]  (+)  [Community] [Settings]
  (+) FAB ─▶ New Habit ─▶ Reminder sheet ─▶ Set Time sheet ;  ✓ FAB saves
Home ─ habit row ─▶ Habit detail (Analytics) ─ pencil ─▶ Edit habit ; Mark complete ─▶ Congratulation popup
Home ─ avatar ─▶ Profile ;  ☰ ─▶ side menu (NOT DESIGNED)
Courses ─ card ─▶ Course detail ─ locked lesson ─▶ Premium (inferred)
Settings ─ "View" ─▶ Profile ;  other rows ─▶ NOT DESIGNED
Profile ─ Billing methods ─▶ store subscription management / Premium (inferred)
```

## Missing from the design (needs a decision or a simple design)

| Missing piece | Where it's referenced | Proposal |
|---|---|---|
| Side menu (☰) | Home, Courses, Community, Settings | Simple drawer in the app's style |
| Edit habit | Pencil on habit detail | Reuse the New Habit form |
| Habit icon picker, color choice | New Habit | Bottom sheet grid |
| Easiness rating input | "Average Easiness Score" | Small 1–10 sheet after completing |
| Empty Home (no habits yet) | First launch after sign-up | Illustration, "Create your first habit", FAB |
| Course search, sort options, filters, saved courses | Courses | Standard sheets and a list |
| Lesson video player | Course detail | Full-screen player |
| Create post, post detail with comments, share | Community | Simple forms and list |
| Edit profile, avatar picker | Profile pencil | Form plus avatar grid (premium avatars locked) |
| Notifications, More customization, Contact, Feedback, Privacy Policy, About | Settings rows | Simple list and text pages; Privacy Policy as a web link |
| Sign out, **delete account** | — | Required by the stores |
| **Sign in with Apple** | Login, Sign Up (iOS) | Required on iOS when Google or Facebook login is offered |
| Loading, error and offline states | All data screens | Shared widgets |
