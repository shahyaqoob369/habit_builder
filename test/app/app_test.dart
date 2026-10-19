import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/design_system/presentation/design_system_page.dart';
import 'package:habit_builder/features/onboarding/data/onboarding_repository.dart';
import 'package:habit_builder/features/onboarding/presentation/onboarding_page.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';
import 'package:habit_builder/features/splash/presentation/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_preferences.dart';

void main() {
  group('App startup', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async => preferences = await createTestPreferences());

    testWidgets('shows the splash for its full duration, then onboarding', (
      tester,
    ) async {
      await tester.pumpFullApp(
        preferences,
        splashDuration: const Duration(seconds: 2),
      );

      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.text('WELCOME TO\nMONUMENTAL\nHABITS'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.byType(SplashPage), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('falls back to onboarding if the startup checks fail', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            splashDurationProvider.overrideWithValue(Duration.zero),
            onboardingRepositoryProvider.overrideWithValue(
              _BrokenOnboardingRepository(preferences),
            ),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('skips onboarding once it has been completed', (tester) async {
      final seen = await tester.runAsync(
        () => createTestPreferences({PreferenceKeys.onboardingCompleted: true}),
      );

      await tester.pumpFullApp(seen!);
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage), findsNothing);
      expect(find.byType(DesignSystemPage), findsOneWidget);
    });
  });
}

class _BrokenOnboardingRepository extends OnboardingRepository {
  const _BrokenOnboardingRepository(super.preferences);

  @override
  bool get isCompleted => throw StateError('storage unavailable');
}
