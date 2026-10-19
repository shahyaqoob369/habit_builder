import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the user has finished (or skipped) onboarding, so it is
/// shown only once.
class OnboardingRepository {
  const OnboardingRepository(this._preferences);

  final SharedPreferencesWithCache _preferences;

  bool get isCompleted =>
      _preferences.getBool(PreferenceKeys.onboardingCompleted) ?? false;

  Future<void> complete() =>
      _preferences.setBool(PreferenceKeys.onboardingCompleted, true);
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(ref.watch(sharedPreferencesProvider)),
);
