# Firebase

| | |
|---|---|
| Project | **Monumental Habits**. The project ID is kept out of this public repo: it's in the local `.firebaserc` and in the owner's [Firebase console](https://console.firebase.google.com) |
| Owner account | The owner's Google account (logged in to the Firebase CLI on the dev Mac) |
| iOS app | bundle ID `com.luminalabs.monumentalhabits` |
| Android app | application ID `com.luminalabs.monumentalhabits` |
| Created | 2026-10-20 (plan step 13) |
| Google Analytics | Linked 2026-10-20 to the owner's "Default Account for Firebase"; one stream per app |

## Config files are local-only

The repo is public, so the owner chose to keep the Firebase app config out of git (they're gitignored):

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist` (the Xcode project references it, so iOS builds need it)
- `android/app/google-services.json`
- `firebase.json`, `.firebaserc`. `firebase.json` also points the CLI at the rules: `"firestore": {"rules": "firestore.rules", "indexes": "firestore.indexes.json"}`. Add that back after running `flutterfire configure` on a fresh clone.

On a fresh clone, or after adding a platform, regenerate them (needs `firebase login` with access to the project). On a fresh clone, first run `firebase use --add` to pick the project, which writes `.firebaserc`:

```bash
dart pub global activate flutterfire_cli   # once; puts flutterfire in ~/.pub-cache/bin
flutterfire configure --project="$(jq -r .projects.default .firebaserc)" --platforms=ios,android \
  --ios-bundle-id=com.luminalabs.monumentalhabits \
  --android-package-name=com.luminalabs.monumentalhabits \
  --out=lib/firebase_options.dart --yes
```

CI (step 26) will write the same files from GitHub secrets before `flutter analyze`.

## How Claude works with it

- The owner logs in once with `firebase login` in their own terminal. Claude then uses the CLI from the dev Mac; no keys or passwords go in chat or the repo.
- Run CLI commands with `--non-interactive`. Otherwise the first-run prompts wait for input and the command hangs.
- Some settings are console-only and need the owner: linking Google Analytics, sign-in providers, the Blaze plan.

## Authentication and Firestore

- **Sign-in:** Email/Password (step 15). Google and Apple come in step 16, Facebook in step 17; until then those buttons say "coming soon" (`AuthFailure.unavailable`).
- **Code:** `FirebaseAuthRepository` (`lib/features/auth/data/`) implements `AuthRepository`. `main` overrides `authRepositoryProvider` with it, and tests use `FakeAuthRepository`.
- **Routing:** the router redirects signed-out users to login (except splash, onboarding and the auth screens) and sends signed-in users away from the auth screens. The splash waits for the saved session. "Keep me signed in" unchecked means the user is signed out on the next launch (preference `auth_keep_signed_in`).
- **Profile:** `users/{uid}` holds `name`, `email`, `marketingOptIn` and `createdAt` (rename adds `updatedAt`). Deleting the account asks for the password, deletes the profile, then the account. **Every later collection under the user must be deleted there too** (step 18 onwards).
- **Rules:** `firestore.rules` (in git). Every user reads and writes only their own profile, and everything else is denied. Deploy them with `firebase deploy --only firestore:rules --non-interactive`.
- **Database:** `(default)` in `nam5` (US multi-region). The location can't be changed.
- **End-to-end test against the real project:** `flutter test integration_test/auth_flow_test.dart -d <simulator id>`. It creates a throwaway account, then deletes it.
- **Screens without Firebase sign-in (debug):** `flutter run --dart-define=FAKE_AUTH=true --dart-define=INITIAL_ROUTE=/home` starts signed in as the demo user.

## Analytics

- **Events:** the catalog is `AnalyticsEvent` in `lib/core/analytics/analytics.dart`. Screen views are logged by the router (`app_router.dart`), named after the route (`home`, `habitDetail`, …). The SDK's automatic screen reporting is off (`FirebaseAutomaticScreenReportingEnabled` in `Info.plist`), so there are no duplicates.
- **No personal data in events:** ids, counts and methods only. There's no `setUserId` yet.
- **No advertising ID:** the iOS Podfile sets `$FirebaseAnalyticsWithoutAdIdSupport` (the log says "IDFA will not be accessible"), and Android removes the `AD_ID` permission. That means no App Tracking Transparency prompt.
- **Opt-out:** Settings → More customization → Share usage data. It calls `setAnalyticsCollectionEnabled`, which is also applied at startup.
- **See events live (DebugView):** launch on the simulator with the debug flag, then open Firebase console → Analytics → DebugView:
  ```bash
  xcrun simctl launch booted com.luminalabs.monumentalhabits -FIRAnalyticsDebugEnabled
  ```
  The flag sticks until the app is launched with `-noFIRAnalyticsDebugEnabled`. Without it, events are uploaded about once an hour, and the reports take up to 24 h.
- **App Store privacy labels** (step 28): Identifiers → Device ID, Usage Data → Product Interaction, and Diagnostics. All are used for Analytics, not linked to the user and not used for tracking. The Play data-safety form gets the same answers.

## Still to do

- Restrict the API keys in Google Cloud: the iOS key to the bundle ID, the Android key to the package name + SHA-1 (step 28; needs `gcloud` or the Cloud console).
- Firestore database and security rules (step 15 onwards).
