# Known Issues & Tech Debt

Severity: 🔴 broken behaviour · 🟠 wrong or misleading UX · 🟡 cleanup. Fix items in the step noted, then move them to *Resolved* with the date.

## Open

- 🟠 **App identity is still the template default.** The bundle and application IDs are `com.example.*`, the Android label is `habit_builder`, and the iOS display name is "Habit Builder". → Step 13 (IDs, needed for Firebase) and step 26 (names, icons).
- 🟡 The native launch splash (`flutter_native_splash`, `assets/native_splash/splash_bg.png`) is still the one from the first commit. → Step 26.
- 🟠 **The design has placeholder copy**: lorem ipsum, "6-month plan for 39.99 usd", "Goggle Play", "TUE 18" twice, "habits makes us". Replace it with real copy when building each screen (RULES §5).
- 🟠 **13 pieces are missing from the design** (side menu, edit habit, empty states, delete account, Sign in with Apple, …). See [SCREENS.md](SCREENS.md#missing-from-the-design-needs-a-decision-or-a-simple-design).

## Resolved

- 2026-10-18 (Step 1): **Klasik heading font missing.** Added Fredoka SemiBold (OFL) as a free stand-in; see DESIGN_SYSTEM.md.
- 2026-10-18 (Step 2): **All issues in the old UI code are gone** because that code was removed for the from-scratch rebuild:
  - login and sign-up pushing each other forever
  - unattached focus nodes
  - the "Wrong password" error never showing
  - fake auth
  - the inverted Show/Hide label
  - the dead Create Account button and the "Creat Account" typo
  - fragile onboarding highlights
  - the broken `toHex()`
  - deprecated `withOpacity` calls and `print`
  - `FontWeight.w900` with no matching font file
  - hardcoded copy
- 2026-10-18 (Step 2): **Colors didn't match Figma.** Replaced by the `AppColors` tokens (`#FDA758`, `#573353`, `#FFF3E9`, …).
- 2026-10-18 (Step 2): The default counter test failed. Replaced with app and theme tests.
- 2026-10-18 (Step 2): CRLF line endings. Added `.gitattributes` (`eol=lf`) and converted the working copy.
- 2026-10-18 (Step 2): Stray `pglite-debug.log`, the very old `intl`, and the unused packages `flutter_svg`, `calendar_date_picker2` and `cupertino_icons` were all removed.
