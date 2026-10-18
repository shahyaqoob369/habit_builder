# Current State — Pre-Rebuild Audit (historical)

> ⚠️ **Historical.** This audit describes the code as it was before the from-scratch rebuild. That code was removed in step 2. For the current structure see [ARCHITECTURE.md](ARCHITECTURE.md); for progress see [PLAN.md](PLAN.md) and [SCREENS.md](SCREENS.md).

_Audit date: 2026-10-18 · Git: 1 commit (`c326e9a first commit`, 2025-07-11) plus a large set of uncommitted changes_

> The Figma design was pulled on 2026-10-18. For how the existing screens differ from it, see [SCREENS.md](SCREENS.md#differences-between-the-design-and-the-existing-code).

## Summary

Only the **pre-auth flow** exists: splash, onboarding, create account and login. These are UI only: there is no real authentication, data layer, state management, routing setup or persistence. None of the habit-tracking features (home, create habit, progress, community, settings, etc.) exist yet.

About 1,500 lines of Dart in 7 files.

## Dependencies

| Package | Version | Used? |
|---|---|---|
| `flutter_native_splash` | ^2.4.6 | ✅ Native splash shows `splash_bg.png` |
| `intl` | ^0.17.0 (old) | ✅ Only for `DateTime.date` |
| `flutter_svg` | ^2.0.10+1 | ❌ Not imported yet, though `email_ic.svg` and `user_ic.svg` are waiting for it |
| `calendar_date_picker2` | ^1.1.7 | ❌ Not imported, probably meant for a later habit calendar |
| `cupertino_icons` | ^1.0.8 | ❌ |
| `flutter_lints` (dev) | ^5.0.0 | ✅ |

## App flow (as wired today)

```
Native splash (splash_bg.png)
  └─▶ SplashScreen           3 s delay, immersive (status/nav bars hidden)
        └─▶ OnboardingScreen  (pushAndRemoveUntil — splash removed from stack)
              ├─ "Skip"         ─▶ CreateAccountScreen (push)
              └─ "Get Started"  ─▶ CreateAccountScreen (push)
                    └─ "Already have an account? Login" ─▶ LoginScreen (push)
                          └─ "Don't have an account? Sign up" ─▶ CreateAccountScreen (push)  ← loops, stack grows
```

There is no route after login or sign-up. Both are dead ends.

## Screen-by-screen

### 1. SplashScreen ([splash_screen.dart](../lib/screens/login/splash_screen.dart))
- Full-screen `splash_bg.png` with "WELCOME TO / MONUMENTAL / HABITS" in navy, 28 px, weight 800.
- Waits 3 s, then replaces the stack with onboarding.
- Hides the system UI (`SystemUiMode.immersive`) and restores `edgeToEdge` in `dispose`.
- **Status:** working. Needs to be checked against Figma.

### 2. OnboardingScreen ([onboarding_screen.dart](../lib/screens/login/onboarding_screen.dart))
- A `PageView` with 4 pages (`splash_1..4.png`), each with a title, an image and a subtitle where some words are highlighted.
- Pages:
  1. WELCOME TO MONUMENTAL HABITS
  2. CREATE NEW HABIT EASILY
  3. KEEP TRACK OF YOUR PROGRESS
  4. JOIN A SUPPORTIVE COMMUNITY
- Bottom bar (placed at `bottom: 150`): Skip, animated dot indicator, Next. The last page shows a "Get Started" button instead.
- Subtitle highlighting uses a hardcoded phrase map and a fragile word-matching algorithm (see KNOWN_ISSUES).
- **Status:** working. Layout and highlighting need rework against Figma.

### 3. CreateAccountScreen ([create_account_screen.dart](../lib/screens/login/create_account_screen.dart)) — *uncommitted, new*
- Header illustration `create_account_ic.png` and the title "CREATE YOUR ACCOUNT".
- Form fields: Name, Email and Password (with a Show/Hide toggle). Each has a prefix icon and a vertical divider, and the icon and hint turn orange when focused.
- Checkboxes: "Keep me signed in" and "Email me about special pricing and more". Their state is held but not used.
- "Creat Account" button (typo). `onPressed` is empty, so the form is never validated or submitted.
- "Or sign in with" divider, then Google and Facebook buttons. These use Material icons and `print()`, and ignore the new `google_ic.png` and `facebook_ic.png`.
- Link to the login screen.
- **Status:** UI only and partly wired. Confirm-password state is declared but there is no field for it.

### 4. LoginScreen ([login_screen.dart](../lib/screens/login/login_screen.dart)) — *uncommitted, rewritten from a stub*
- Full-height `splash_bg.png` header with "WELCOME TO MONUMENTAL HABITS" and "Continue with Google" / "Continue with Facebook" buttons (TODO).
- White card with rounded top corners: "Log in with email", email and password fields, Login button, Forgot Password (TODO), and a Sign-up link.
- A floating "?" help button in the top right (TODO).
- `_login()` validates the form, then **fakes** authentication: any password other than `"correct_password"` sets `_passwordErrorText`. That error is never shown in the UI.
- **Status:** UI only. Several wiring bugs (see KNOWN_ISSUES).

## Common code

- [lib/main.dart](../lib/main.dart): `MaterialApp` with Material 3, Manrope font, `scaffoldBackgroundColor: AppColor.bg`, a seed color from `AppColor.primary`, and home set to `SplashScreen`.
- [lib/common/color_extensions.dart](../lib/common/color_extensions.dart): the `AppColor` palette, the `HexColor` extension, the `AppContext` extension (size and navigation) and the `DateTimeExtension`.
- [lib/common/globe.dart](../lib/common/globe.dart): `Globe.appName`.

## Assets

| File | Size | Used by |
|---|---|---|
| `splash_bg.png` | 414×896 | Native splash, SplashScreen, LoginScreen |
| `splash_1..4.png` | ~400×400 | Onboarding pages |
| `create_account_ic.png` | 376×400 | CreateAccountScreen *(uncommitted)* |
| `google_ic.png`, `facebook_ic.png` | 39 px, 55 px | **Unused** *(uncommitted)* |
| `email_ic.svg` (`#573353`), `user_ic.svg` (`#FDA758`) | 17 px | **Unused** *(uncommitted)* |
| Manrope TTFs (200–800) | — | App-wide font |

The asset sizes (414×896 = iPhone 11 / XR) suggest the Figma frames are **414 × 896**.

## Quality checks (run 2026-10-18)

- `flutter analyze`: **16 issues** (3 warnings for unused fields, the rest are deprecated APIs and `avoid_print`). No errors.
- `flutter test`: **fails**. The test is the default counter template and has nothing to do with this app.

## Uncommitted work at audit time

All of this is unstaged and has never been committed. **Commit it as a baseline before starting the Figma build.**

- New: `create_account_screen.dart`, 5 image/SVG assets, iOS and macOS `Podfile` and `Podfile.lock`.
- Modified: `login_screen.dart` (stub replaced by full UI), `onboarding_screen.dart` (now routes to Create Account instead of Login), `color_extensions.dart` (`bgSecondary` changed from 20 % orange to solid `#FEF3DE`), Xcode project, scheme and xcconfig files (CocoaPods integration), `pubspec.lock`.
