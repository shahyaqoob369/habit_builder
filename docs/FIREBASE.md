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

CI (`.github/workflows/ci.yml`) doesn't use the real config or any secret. It copies the placeholder `tool/ci/firebase_options_stub.dart` to `lib/firebase_options.dart`, which is enough for `flutter analyze` and `flutter test`, because the unit and widget tests never call Firebase. The end-to-end tests in `integration_test/` need the real project, so they run only on the dev Mac (see below).

## How Claude works with it

- The owner logs in once with `firebase login` in their own terminal. Claude then uses the CLI from the dev Mac; no keys or passwords go in chat or the repo.
- Run CLI commands with `--non-interactive`. Otherwise the first-run prompts wait for input and the command hangs.
- Some settings are console-only and need the owner: linking Google Analytics, sign-in providers, the Blaze plan.

## Authentication and Firestore

- **Sign-in:** Email/Password (step 15), Google and Apple (step 16, iOS; enabled in the console 2026-10-21). No Facebook (owner). Google uses `google_sign_in`, which reads `CLIENT_ID` from `GoogleService-Info.plist`; its URL scheme (`REVERSED_CLIENT_ID`) comes from the gitignored `ios/Flutter/Firebase.xcconfig`, which `Info.plist` reads as `$(GOOGLE_REVERSED_CLIENT_ID)`. Recreate it after `flutterfire configure`:
  ```bash
  echo "GOOGLE_REVERSED_CLIENT_ID = $(/usr/libexec/PlistBuddy -c 'Print :REVERSED_CLIENT_ID' ios/Runner/GoogleService-Info.plist)" > ios/Flutter/Firebase.xcconfig
  ```
  Apple uses Firebase's native flow (`signInWithProvider(AppleAuthProvider())`) and the `Runner.entitlements` capability; the app is signed with the owner's team (`DEVELOPMENT_TEAM`).
- **Apple sign-in key (owner, before release):** Apple requires apps to revoke Sign in with Apple when the account is deleted, and Firebase needs a key for that. In the Apple Developer portal: register the App ID `com.luminalabs.monumentalhabits` with Sign In with Apple, create a key with Sign in with Apple for that App ID, and download the `.p8` (once only). Then in the Firebase console → Authentication → Apple → **OAuth code flow configuration**: team ID, key ID and the `.p8` contents. The key never goes in chat or the repo.
- **Code:** `FirebaseAuthRepository` (`lib/features/auth/data/`) implements `AuthRepository`. `main` overrides `authRepositoryProvider` with it, and tests use `FakeAuthRepository`.
- **Routing:** the router redirects signed-out users to login (except splash, onboarding and the auth screens) and sends signed-in users away from the auth screens. The splash waits for the saved session. "Keep me signed in" unchecked means the user is signed out on the next launch (preference `auth_keep_signed_in`).
- **Profile:** `users/{uid}` holds `name`, `email`, `marketingOptIn` and `createdAt` (rename adds `updatedAt`). Deleting the account asks for the password (or a Google or Apple sign-in again), deletes the profile, then the account. A new Google or Apple user gets a profile on their first sign-in (`marketingOptIn` false). **Every later collection under the user must be deleted there too** (step 18 onwards).
- **Habits:** `users/{uid}/habits/{habitId}`, one document per habit with its days inside (`HabitMapper` documents the fields). `FirestoreHabitRepository` doesn't wait for the server, so it works offline and Firestore syncs later. `main` gives each signed-in user their own repository.
- **Feedback:** `users/{uid}/feedback/{id}` (`message`, `createdAt`, `platform`, `appVersion`). Read it in the console: Firestore → query the `feedback` collection group.
- **Community:** `posts/{id}` (+ `likes/{uid}`, `comments/{id}`), `reports/{id}` (console only) and `users/{uid}/blocked/{memberId}` (layout in `FirestoreCommunityRepository`). There are no Cloud Functions (Spark plan): each like or comment updates its post's counter in the same batch, and the rules check both sides. Deleting an account removes the user's posts, comments, likes and blocks. **Moderation:** read `reports` in the console and delete the post there.
- **Indexes:** `firestore.indexes.json` enables collection-group queries on `likes.uid` and `comments.authorId`. Deploy with `firebase deploy --only firestore --non-interactive`.
- **Rules:** `firestore.rules` (in git). Every user reads and writes only their own profile, habits and feedback; signed-in users read the community, the fields are validated, and everything else is denied. Deploy them with `firebase deploy --only firestore:rules --non-interactive`.
- **Database:** `(default)` in `nam5` (US multi-region). The location can't be changed.
- **End-to-end tests against the real project:** `flutter test integration_test/<name>_test.dart -d <simulator id>` for `auth_flow`, `habits_flow`, `community_flow` (two users) and `app_flow` (`app_flow` drives the real UI). Each creates a throwaway `integration-…@example.com` account, then deletes it (`app_flow` deletes it even when it fails). To check for leftovers: `firebase auth:export <file> --format=json`, then delete the file.
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
