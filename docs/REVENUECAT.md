# RevenueCat (Premium)

| | |
|---|---|
| Project | **Monumental Habits** in the owner's RevenueCat account (created 2026-10-30, plan step 22). The account has other apps' projects too; never touch them |
| Apps | **Monumental Habits (iOS)**: App Store, bundle ID `com.luminalabs.monumentalhabits`. **Test Store**: RevenueCat's built-in fake store, for debug builds |
| Entitlement | `premium`: every product below unlocks it |
| Offering | `default` (current): packages `$rc_monthly`, `$rc_annual`, `$rc_lifetime` |

## Products

The same store identifiers exist in both apps. Each package holds the App Store product and its Test Store twin.

| Package | Product ID | Type | Test Store price |
|---|---|---|---|
| `$rc_monthly` | `premium_monthly` | auto-renewing subscription, 1 month | $19.00 |
| `$rc_annual` | `premium_yearly` | auto-renewing subscription, 1 year | $29.00 |
| `$rc_lifetime` | `premium_lifetime` | non-consumable | $49.00 |

The Test Store prices are the design's. Real prices are set per product in App Store Connect; the app always shows the store's own price string.

## Paywall settings without an app update

The offering's **metadata** (RevenueCat → Product catalog → Offerings → default → Metadata) controls the paywall:

```json
{
  "most_popular": "$rc_annual",
  "badges": { "$rc_lifetime": "-75%" },
  "offer_percent": 60
}
```

- `most_popular`: the package with the "Most Popular" header.
- `badges`: corner badges per package.
- `offer_percent`: shows the "60 % off" card with a 24 h countdown from the first time the device sees it. **Not set yet.** Only set it while App Store Connect really sells the plans at that discount (for example an introductory offer); a fake discount or countdown breaks App Review guideline 3.1.2 / 5.6.

## In the app

- `RevenueCatPremiumRepository` (`lib/features/premium/data/`) implements `PremiumRepository`. Purchases belong to the Firebase user (`Purchases.logIn(uid)`), so Premium follows the account. `premiumOfferingFrom` maps the offering to the paywall's plans (unit tested).
- `lib/app/premium_backend.dart` picks the SDK key: the **Test Store in debug builds** (purchases are fake and free), the **App Store in iOS release builds**, and nothing on Android release builds yet (no plans, never Premium).
- `isPremiumProvider` (the `premium` entitlement) lifts the 3-habit limit and unlocks the courses.
- **SDK keys** are public keys, but like the Firebase config they're kept out of this public repo: `lib/revenuecat_options.dart` is gitignored. Recreate it from RevenueCat → Apps → each app → **Public API key** (`RevenueCatOptions.appStore`, `RevenueCatOptions.testStore`; shape in `tool/ci/revenuecat_options_stub.dart`, which CI uses).
- **Secret API key:** Claude sets up the project through the REST API v2 with a project-scoped secret key that stays on the dev Mac, never in the repo or chat.

## Testing purchases

- **Now (Test Store):** run a debug build (`flutter run -d <iPhone>`). The paywall shows the three plans; buying shows RevenueCat's test sheet, where you choose success or failure. Restore works the same way.
- **Later (App Store sandbox):** needs the App Store Connect steps below, then a release or TestFlight build with a Sandbox Apple Account (Settings → Developer → Sandbox Apple Account on the iPhone).

## Owner steps in App Store Connect (still to do)

1. **Business** → sign the **Paid Apps** agreement and add bank and tax details. Without them, no purchase works, even in the sandbox.
2. **Apps → +** → New App: platform iOS, name "Monumental Habits", bundle ID `com.luminalabs.monumentalhabits`, SKU e.g. `monumentalhabits`.
3. In the app → **Monetization → Subscriptions**: a subscription group "Premium" with `premium_monthly` (1 month) and `premium_yearly` (1 year). **In-App Purchases**: `premium_lifetime` (non-consumable). Set prices, names and a review screenshot for each.
4. **Users and Access → Integrations → In-App Purchase** → generate a key, download the `.p8` (once only) and upload it in RevenueCat → Apps → Monumental Habits (iOS) → **In-app purchase key configuration**, with the Key ID and Issuer ID. RevenueCat needs it to verify purchases.
