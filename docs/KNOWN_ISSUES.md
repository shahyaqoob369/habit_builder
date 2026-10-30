# Known Issues & Tech Debt

Severity: 🔴 broken behaviour · 🟠 wrong or misleading UX · 🟡 cleanup. Fix items in the step noted, then move them to *Resolved* with the date.

## Open

- 🟠 **Owner decision: app icon.** The Figma kit has no app icon, so since step 27 the launcher icon is a stand-in: the kit's teepee on the cream background. To replace it, change the artwork in `tool/figma/build_app_icon.py` (or replace its outputs), run it, then `dart run flutter_launcher_icons` (see MEMORY gotchas). The home-screen name "Monumental Habits" may be shortened by iOS on small icons ("Monumental Ha…"); a shorter display name is the owner's call. The desktop folders (macOS, Windows, Linux) keep `com.example` IDs; they aren't targets.
- 🟡 Onboarding dots: Figma shows a soft glow under the dots (shadow blur 60 at 15 %); on Android it renders much fainter. Cosmetic.
- 🟠 **The design has placeholder copy**: lorem ipsum, "6-month plan for 39.99 usd", "Goggle Play", "TUE 18" twice, "habits makes us". Replace it with real copy when building each screen (RULES §5).
- 🟡 Login: the design has a stray 1 pt line across the screen at y 677 (behind the password field, visible only at its sides). Left out as a design leftover.
- 🟡 Pages that scroll (Sign Up on small phones) slide their artwork under the transparent status bar. Standard edge-to-edge behaviour; revisit in step 25 if it looks busy.
- 🟠 **Owner decision: text contrast.** The design's muted text (for example the weekday letters, `textMuted` on white) has a contrast ratio of 2.67:1; WCAG AA asks 4.5:1 for small text. It is kept as designed (pixel-perfect). Darkening `textMuted` would fix it everywhere in one token. App Review does not require it.
- 🟡 **Community:** the feed shows the newest 100 posts (no paging yet). Posts keep the author's name from when they were written, and everyone has the same illustrated avatar. Moderation is manual: read `reports` in the Firebase console and delete the post there. Counters are kept by the security rules, not Cloud Functions (Spark plan).
- 🟡 **Reminders:** tapping a reminder opens the habit only while the app is running or in the background; from a cold start the app opens on Home. Over 64 reminders (many habits × weekdays × times), the latest habits' reminders are dropped (iOS limit).
- 🟡 **The free-plan habit limit (3) is enforced in the app only.** The Firestore rules can enforce it once Premium status is stored server-side (RevenueCat, step 22).
- 🟠 **Apple sign-in key (before release):** Apple requires apps to revoke Sign in with Apple when an account is deleted. Firebase does this only once the owner adds an Apple key under Authentication → Apple → OAuth code flow ([FIREBASE.md](FIREBASE.md)). Until then deletion still works but skips the revocation (logged).
- 🟡 **Android sign-in:** Google needs the app's SHA-1 in Firebase, and Apple (hidden on Android) needs a Services ID and the web flow. Both come with the Android release.
- 🟡 Apple shares the user's name only on their first sign-in; if it's missing, the profile has an empty name until the user sets one.
- 🟡 **CocoaPods:** Firebase stops publishing iOS SDK releases to CocoaPods in October 2026 (`firebase_core` pins 12.19.0). Move the iOS build to Swift Package Manager before the next Firebase upgrade.
- 🟠 **Account deletion** removes the profile and habits (`_userCollections` in `FirebaseAuthRepository`). Every later per-user collection must be added there, or handled by a Cloud Function (needs the Blaze plan).
- 🟡 Home: the day strip scrolls sideways and opens on today, fully visible at the right (Figma cuts the last column at the screen edge). Tapping a cell cycles not marked → done → missed (not in the design). The avatar is the illustrated one, not the kit's stock photo.
- 🟡 New Habit: the design has two variants (screen 10: name field + icon button; screen 11: "Habit Name" card). Screen 10 is built. The icon and color picker, frequency presets and Delete (edit mode) aren't in the design; they're built in its style (owner Q4–Q6 defaults). Days off show as half cells, as in the design. The time picker's lower ±2 row shows the real next hour (the design repeats "08").
- 🟡 Habit detail: the summary card puts the repeat icon next to "Repeat: …" and the bell next to "Reminders" (Figma has them swapped). The easiness rating sheet after "Mark as Complete" isn't designed (Q2 default). The congratulation popup shows at streaks of 7, 21, 30, 66 and 100 days (Q12 default).
- 🟡 Courses: search (field in place of the banner), the sort and filter sheets, saved courses and "Show all N lessons" aren't designed; they're built in its style. Lessons don't play yet (step 23), and locked lessons show a note until the paywall exists (step 12). Sample lesson titles replace "Adopting Prompts to Covid-19".
- 🟡 Community: the composer card above the feed, the post screen with comments, and Report / Hide author on long press aren't in the design (Report and block are required by App Store guideline 1.2 for user posts). The design's sample post naming a real author was made generic. Moderation tooling for reports comes with the backend (step 24).
- 🟠 **Owner must provide before release:** the support email, privacy policy URL and terms of service URL (`lib/core/config/app_config.dart` holds placeholders). Contact and Privacy Policy open them.
- 🟡 Profile: "Total Work Hours" is replaced by **Perfect Days** (Q3); the name line shows the email; Profile sits under the Settings tab (Figma highlights Community there). Sign out and **Delete account** (App Store 5.1.1(v)) are added at the bottom. Settings sub-pages (Notifications, More customization), the feedback form and About aren't designed; built in its style.
- 🟠 **Owner decision: the 60 % offer.** The design shows "60 % off your upgrade" with a countdown. The app shows it only if the RevenueCat offering's metadata sets `offer_percent`, which should match a real App Store introductory offer ([REVENUECAT.md](REVENUECAT.md)); a fake discount risks App Review rejection.
- 🟡 Premium: the design's placeholder plan text ("6-month plan for 39.99 usd") is replaced by billing descriptions, and "Goggle Play" by the platform's store. Prices come from RevenueCat (Test Store prices in debug builds until App Store Connect has the products). The chosen plan has an orange outline (not designed). Free users opening a locked lesson get the paywall; the habit limit follows the `premium` entitlement (step 22); avatars aren't gated (no picker yet).
- 🟠 **13 pieces are missing from the design** (side menu, edit habit, empty states, delete account, Sign in with Apple, …). See [SCREENS.md](SCREENS.md#missing-from-the-design-needs-a-decision-or-a-simple-design).

## Resolved

- 2026-10-21 (step 16): **Google sign-in said "coming soon".** Google and Apple sign-in work on iOS; Facebook was dropped (owner).
- 2026-10-21 (step 27): the launcher icons were the Flutter default; now the teepee stand-in on iOS and Android (adaptive icon). The native splash had already matched Figma since step 3.
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
