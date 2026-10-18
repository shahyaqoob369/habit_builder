# Known Issues & Tech Debt

Found during the 2026-10-18 audit. Severity: 🔴 broken behaviour · 🟠 wrong or misleading UX · 🟡 cleanup.

Many of these will go away when the screens are rebuilt from Figma. Check this list before reusing any existing code.

## Open

### Navigation
- 🔴 **Login and sign-up push each other forever.** `CreateAccountScreen` → `context.push(LoginScreen())` ([create_account_screen.dart:567](../lib/screens/login/create_account_screen.dart#L567)) and `LoginScreen` → `context.push(CreateAccountScreen())` ([login_screen.dart:299](../lib/screens/login/login_screen.dart#L299)). Each tap adds a new route to the stack. Use `pushReplacement`, or a router.
- 🔴 **No destination after auth.** Login and sign-up don't navigate anywhere, because no home screen exists yet.
- 🟡 Splash calls `Navigator.pushAndRemoveUntil` after `await Future.delayed` with no `mounted` check ([splash_screen.dart:23-35](../lib/screens/login/splash_screen.dart#L23-L35)).

### LoginScreen
- 🔴 **Focus nodes never attached.** `_emailFocusNode` and `_passwordFocusNode` are created but never passed to the `TextFormField`s, so the focus styling never runs ([login_screen.dart:195-253](../lib/screens/login/login_screen.dart#L195-L253)).
- 🔴 **"Wrong password" error is never shown.** `_passwordErrorText` is set but not bound to `InputDecoration.errorText` ([login_screen.dart:69-73](../lib/screens/login/login_screen.dart#L69-L73)).
- 🔴 **Fake auth.** The only accepted password is the literal `"correct_password"` ([login_screen.dart:69](../lib/screens/login/login_screen.dart#L69)).
- 🟠 Show/Hide label is inverted: it says "Show" while the password is visible ([login_screen.dart:233](../lib/screens/login/login_screen.dart#L233)).
- 🟠 Social buttons use the stand-in icons `Icons.g_mobiledata_rounded` and `Icons.facebook` instead of the brand assets.
- 🟠 Forgot Password and the help "?" button are TODO no-ops.
- 🟡 Unused field `_isEmailFocused`. A misleading import comment on line 3.

### CreateAccountScreen
- 🔴 **The Create Account button does nothing.** `onPressed: () {}` never calls `_formKey.currentState!.validate()` ([create_account_screen.dart:432](../lib/screens/login/create_account_screen.dart#L432)).
- 🟠 Typo "Creat Account" ([create_account_screen.dart:441](../lib/screens/login/create_account_screen.dart#L441)).
- 🟠 Google and Facebook buttons use Material icons and `print()`. The new `google_ic.png` and `facebook_ic.png` are unused.
- 🟠 Text the user types is orange (`AppColor.primary`), and hints and dividers use `Colors.black12`, which is very low contrast.
- 🟡 Dead state: `_isLoading` and `_obscureConfirmPassword` are `final` and never change. `_confirmPasswordController` has no field. `_keepMeSignedIn` and `_emailMeDetails` are never read.
- 🟡 The three text fields repeat about 40 lines of `InputDecoration` each. Extract a shared `AppTextField`.

### OnboardingScreen
- 🟠 **Subtitle highlighting is fragile.** The map key `"WE CAN, BETTER VERSION OF"` is one string with a comma, so "CAN" never matches. Any word that appears in a highlight phrase is highlighted wherever it occurs, for example every "YOUR" ([onboarding_screen.dart:250-291](../lib/screens/login/onboarding_screen.dart#L250-L291)). Store highlight spans in the page data instead.
- 🟠 The control row is placed at `bottom: 150` with absolute positioning, so it can overlap content on short screens.
- 🟡 `pageArr` is an untyped `List` of maps. Use a small model class.
- 🟡 `PageController` is never disposed.

### Design mismatch (found when Figma was pulled, 2026-10-18)
- 🟠 **`AppColor` doesn't match Figma.** Primary is `#FEA800` but should be `#FDA758`. Text is navy `#1B237E` but should be plum `#573353`. Background is `#F5F5F5` / `#FEF3DE` but should be `#FFF3E9`. See [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md#mapping-from-the-current-code-appcolor).
- 🟠 The onboarding subtitles and highlights differ from the design. The design repeats one subtitle with the "HELP YOU" and "YOURSELF." spans in orange.

### Common
- 🔴 **`HexColor.toHex()` is wrong on this SDK.** `a` is now a 0–1 double, so `a.toInt()` is 0 or 1. `red`, `green` and `blue` are also deprecated ([color_extensions.dart:36-41](../lib/common/color_extensions.dart#L36-L41)).
- 🟡 `AppContext.pop()` is `void … async` and returns a value. Make it plain `void`.
- 🟡 About 9 `withOpacity()` calls (deprecated). Use `withValues(alpha:)`.
- 🟡 `FontWeight.w900` is used, but Manrope 900 is not bundled.
- 🟡 Hardcoded copy everywhere, with no localization setup.

### Project and config
- 🔴 `test/widget_test.dart` is the Flutter counter template and **fails**.
- 🟠 Bundle and application IDs are still `com.example.*`. The Android label is `habit_builder` and the iOS display name is "Habit Builder". Both need the real name.
- 🟡 `intl ^0.17.0` is very old. `flutter_svg` and `calendar_date_picker2` are declared but unused.
- 🟡 There is a stray empty file `pglite-debug.log` in the repo root.
- 🟡 The first commit used CRLF line endings, so git warns on every diff. Consider adding `.gitattributes` with `* text=auto eol=lf`.
- 🟡 Nothing has been committed since the initial commit. The login and sign-up work exists only in the working tree.

## Resolved

- 2026-10-18 (Step 1): **The Klasik heading font was missing.** Fredoka SemiBold (OFL) was added as a free stand-in; see DESIGN_SYSTEM.md. Screens start using it in step 3.
