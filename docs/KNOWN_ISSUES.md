# Known Issues & Tech Debt

Severity: 🔴 broken behaviour · 🟠 wrong or misleading UX · 🟡 cleanup. Fix items in the step noted, then move them to *Resolved* with the date.

## Open

- 🟡 **App identity:** the launcher icons and the native splash are still the template defaults → step 27. The desktop folders (macOS, Windows, Linux) keep `com.example` IDs; they aren't targets.
- 🟡 Onboarding dots: Figma shows a soft glow under the dots (shadow blur 60 at 15 %); on Android it renders much fainter. Cosmetic.
- 🟠 **The design has placeholder copy**: lorem ipsum, "6-month plan for 39.99 usd", "Goggle Play", "TUE 18" twice, "habits makes us". Replace it with real copy when building each screen (RULES §5).
- 🟡 Login: the design has a stray 1 pt line across the screen at y 677 (behind the password field, visible only at its sides). Left out as a design leftover.
- 🟡 Pages that scroll (Sign Up on small phones) slide their artwork under the transparent status bar. Standard edge-to-edge behaviour; revisit in step 25 if it looks busy.
- 🟡 **Reminders:** tapping a reminder opens the habit only while the app is running or in the background; from a cold start the app opens on Home. Over 64 reminders (many habits × weekdays × times), the latest habits' reminders are dropped (iOS limit).
- 🟡 **The free-plan habit limit (3) is enforced in the app only.** The Firestore rules can enforce it once Premium status is stored server-side (RevenueCat, step 22).
- 🟠 **Google and Facebook sign-in say "coming soon"** until steps 16 and 17. Email sign-in is real (Firebase) since step 15.
- 🟡 **CocoaPods:** Firebase stops publishing iOS SDK releases to CocoaPods in October 2026 (`firebase_core` pins 12.19.0). Move the iOS build to Swift Package Manager before the next Firebase upgrade.
- 🟠 **Account deletion** removes the profile and habits (`_userCollections` in `FirebaseAuthRepository`). Every later per-user collection must be added there, or handled by a Cloud Function (needs the Blaze plan).
- 🟡 Home: the day strip scrolls sideways and opens on today, fully visible at the right (Figma cuts the last column at the screen edge). Tapping a cell cycles not marked → done → missed (not in the design). The avatar is the illustrated one, not the kit's stock photo.
- 🟡 New Habit: the design has two variants (screen 10: name field + icon button; screen 11: "Habit Name" card). Screen 10 is built. The icon and color picker, frequency presets and Delete (edit mode) aren't in the design; they're built in its style (owner Q4–Q6 defaults). Days off show as half cells, as in the design. The time picker's lower ±2 row shows the real next hour (the design repeats "08").
- 🟡 Habit detail: the summary card puts the repeat icon next to "Repeat: …" and the bell next to "Reminders" (Figma has them swapped). The easiness rating sheet after "Mark as Complete" isn't designed (Q2 default). The congratulation popup shows at streaks of 7, 21, 30, 66 and 100 days (Q12 default).
- 🟡 Courses: search (field in place of the banner), the sort and filter sheets, saved courses and "Show all N lessons" aren't designed; they're built in its style. Lessons don't play yet (step 23), and locked lessons show a note until the paywall exists (step 12). Sample lesson titles replace "Adopting Prompts to Covid-19".
- 🟡 Community: the composer card above the feed, the post screen with comments, and Report / Hide author on long press aren't in the design (Report and block are required by App Store guideline 1.2 for user posts). The design's sample post naming a real author was made generic. Moderation tooling for reports comes with the backend (step 24).
- 🟠 **Owner must provide before release:** the support email, privacy policy URL and terms of service URL (`lib/core/config/app_config.dart` holds placeholders). Contact and Privacy Policy open them.
- 🟡 Profile: "Total Work Hours" is replaced by **Perfect Days** (Q3); the name line shows the email; Profile sits under the Settings tab (Figma highlights Community there). Sign out and **Delete account** (App Store 5.1.1(v)) are added at the bottom. Settings sub-pages (Notifications, More customization), the feedback form and About aren't designed; built in its style.
- 🟡 Premium: the design's placeholder plan text ("6-month plan for 39.99 usd") is replaced by billing descriptions, and "Goggle Play" by the platform's store. Prices come from the store interface (sample prices until RevenueCat, step 22). The chosen plan has an orange outline (not designed). Free users opening a locked lesson get the paywall; habit limits and avatar gating come with step 22.
- 🟠 **13 pieces are missing from the design** (side menu, edit habit, empty states, delete account, Sign in with Apple, …). See [SCREENS.md](SCREENS.md#missing-from-the-design-needs-a-decision-or-a-simple-design).

## Resolved

- 2026-10-20 (Step 13): **Template app identity.** The bundle and application IDs are now `com.luminalabs.monumentalhabits`, and the app is called "Monumental Habits" on iOS and Android.
- 2026-10-19 (Step 3): **The native launch splash** was the old low-res image with a black status bar. It's now the new 2× artwork with a transparent status bar (Android 12+: cream color).

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
