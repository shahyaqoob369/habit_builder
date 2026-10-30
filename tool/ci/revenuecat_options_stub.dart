// Placeholder RevenueCat keys for CI. The real `lib/revenuecat_options.dart`
// is kept out of git; CI copies this file in its place so the app compiles.
// The tests never call RevenueCat. See docs/REVENUECAT.md.
abstract final class RevenueCatOptions {
  static const appStore = 'ci-placeholder';
  static const testStore = 'ci-placeholder';
}
