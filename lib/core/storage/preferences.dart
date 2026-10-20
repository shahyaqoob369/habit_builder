import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys stored in [SharedPreferencesWithCache]. Every key must be listed in
/// [all], which is the cache's allow-list.
abstract final class PreferenceKeys {
  static const onboardingCompleted = 'onboarding_completed';
  static const habitReminders = 'settings_habit_reminders';
  static const communityNotifications = 'settings_community_notifications';
  static const showQuote = 'settings_show_quote';

  static const Set<String> all = {
    onboardingCompleted,
    habitReminders,
    communityNotifications,
    showQuote,
  };
}

/// Creates the app's preferences store. Called once at startup in `main`.
Future<SharedPreferencesWithCache> createPreferences() {
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: PreferenceKeys.all,
    ),
  );
}

/// The app's preferences store. Overridden in `main` (and in tests) with the
/// instance from [createPreferences].
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  ),
);
