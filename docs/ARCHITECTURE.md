# Architecture

## Current structure

```
lib/
├── main.dart                       MaterialApp, theme, home: SplashScreen
├── common/
│   ├── color_extensions.dart       AppColor palette + Color/BuildContext/DateTime extensions
│   └── globe.dart                  Globe.appName
└── screens/
    └── login/
        ├── splash_screen.dart
        ├── onboarding_screen.dart
        ├── create_account_screen.dart
        └── login_screen.dart
```

- **State:** `StatefulWidget` + `setState` only.
- **Navigation:** imperative `Navigator.push` through `context.push()`. There are no named routes.
- **Data:** none. No models, repositories, persistence or network.
- **Theme:** a minimal `ThemeData`. Styles are written inline in each widget.

This is fine for a UI prototype, but it won't scale to the full habit app.

## Proposed target structure

This is a proposal. Confirm it with the project owner before the first feature build (see *Open decisions* in [PLAN.md](PLAN.md)).

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    MaterialApp.router
│   ├── router.dart                 route table + auth/onboarding redirects
│   └── theme/
│       ├── app_colors.dart         tokens from Figma
│       ├── app_text_styles.dart    type scale from Figma
│       ├── app_spacing.dart
│       └── app_theme.dart          ThemeData built from the above
├── core/
│   ├── extensions/                 context, date, color helpers
│   ├── widgets/                    PrimaryButton, AppTextField, SocialButton, ...
│   └── utils/
├── data/
│   ├── models/                     Habit, HabitLog, User, ...
│   ├── repositories/               HabitRepository, AuthRepository
│   └── sources/                    local DB / remote API
└── features/
    ├── onboarding/   (splash, onboarding)
    ├── auth/         (login, create_account, forgot_password)
    ├── home/
    ├── habits/       (create/edit habit, habit detail)
    ├── progress/
    ├── community/
    └── settings/     (profile, settings, notifications)
```

Each feature folder holds `screens/`, `widgets/` and its state (controllers or providers).

## Principles

1. **Design tokens in one place.** Screens never hardcode colors, font sizes or radii.
2. **Shared widgets for repeated UI.** If two screens draw the same thing, it belongs in `core/widgets/`.
3. **UI does not talk to storage directly.** Screens call state classes, which call repositories.
4. **Keep it simple.** Don't add layers a feature doesn't need yet.

## Migration path

There is no need for a big-bang rewrite. When a screen is rebuilt from Figma:
1. Move it into its `features/` folder.
2. Replace inline styles with theme tokens and shared widgets.
3. Fix the related items in [KNOWN_ISSUES.md](KNOWN_ISSUES.md).
