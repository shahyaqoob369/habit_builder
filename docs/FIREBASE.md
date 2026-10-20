# Firebase

| | |
|---|---|
| Project | **Monumental Habits** · ID `monumental-habits-app` · [console](https://console.firebase.google.com/project/monumental-habits-app/overview) |
| Owner account | The owner's Google account (logged in to the Firebase CLI on the dev Mac) |
| iOS app | bundle ID `com.luminalabs.monumentalhabits` |
| Android app | application ID `com.luminalabs.monumentalhabits` |
| Created | 2026-10-20 (plan step 13) |

## Config files are local-only

The repo is public, so the owner chose to keep the Firebase app config out of git (they're gitignored):

- `lib/firebase_options.dart`
- `ios/Runner/GoogleService-Info.plist` (the Xcode project references it, so iOS builds need it)
- `android/app/google-services.json`
- `firebase.json`, `.firebaserc`

On a fresh clone, or after adding a platform, regenerate them (needs `firebase login` with access to the project):

```bash
dart pub global activate flutterfire_cli   # once; puts flutterfire in ~/.pub-cache/bin
flutterfire configure --project=monumental-habits-app --platforms=ios,android \
  --ios-bundle-id=com.luminalabs.monumentalhabits \
  --android-package-name=com.luminalabs.monumentalhabits \
  --out=lib/firebase_options.dart --yes
```

CI (step 26) will write the same files from GitHub secrets before `flutter analyze`.

## How Claude works with it

- The owner logs in once with `firebase login` in their own terminal. Claude then uses the CLI from the dev Mac; no keys or passwords go in chat or the repo.
- Run CLI commands with `--non-interactive`. Otherwise the first-run prompts wait for input and the command hangs.
- Some settings are console-only and need the owner: linking Google Analytics, sign-in providers, the Blaze plan.

## Still to do

- Restrict the API keys in Google Cloud: the iOS key to the bundle ID, the Android key to the package name + SHA-1 (step 28; needs `gcloud` or the Cloud console).
- Link Google Analytics (step 14, owner in the console).
- Firestore database and security rules (step 15 onwards).
