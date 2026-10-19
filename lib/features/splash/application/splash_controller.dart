import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/features/onboarding/data/onboarding_repository.dart';

/// How long the splash stays on screen. Overridden with zero in tests.
final splashDurationProvider = Provider<Duration>(
  (ref) => const Duration(seconds: 2),
);

/// Where to go once the splash has been shown.
///
/// Startup checks (auth, from plan step 14) will run here in parallel with
/// the minimum splash time.
final FutureProvider<AppRoute> splashDestinationProvider =
    FutureProvider.autoDispose<AppRoute>((ref) async {
      await Future<void>.delayed(ref.watch(splashDurationProvider));
      final onboardingDone = ref.read(onboardingRepositoryProvider).isCompleted;
      return onboardingDone ? AppRoute.login : AppRoute.onboarding;
    });
