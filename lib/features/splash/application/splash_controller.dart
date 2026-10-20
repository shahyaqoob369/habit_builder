import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/onboarding/data/onboarding_repository.dart';

/// How long the splash stays on screen. Overridden with zero in tests.
final splashDurationProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// Where to go once the splash has been shown: Home when signed in,
/// otherwise login (or onboarding the first time).
///
/// The saved session is restored while the splash is up. A user who signed
/// up without "Keep me signed in" is signed out here, on the next launch.
final FutureProvider<AppRoute> splashDestinationProvider =
    FutureProvider.autoDispose<AppRoute>((ref) async {
      final auth = ref.read(authRepositoryProvider);
      final preferences = ref.read(sharedPreferencesProvider);
      final (_, restored) = await (
        Future<void>.delayed(ref.watch(splashDurationProvider)),
        auth.authStateChanges().first,
      ).wait;
      var user = restored;
      final keep = preferences.getBool(PreferenceKeys.keepSignedIn) ?? true;
      if (user != null && !keep) {
        await auth.signOut();
        user = null;
      }
      if (user != null) return AppRoute.home;
      final onboardingDone = ref.read(onboardingRepositoryProvider).isCompleted;
      return onboardingDone ? AppRoute.login : AppRoute.onboarding;
    });
