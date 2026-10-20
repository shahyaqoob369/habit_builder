import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';

import '../../../helpers/test_preferences.dart';

void main() {
  group('splashDestinationProvider', () {
    Future<AppRoute> destination(
      Map<String, Object> stored, {
      FakeAuthRepository? auth,
    }) async {
      final container = ProviderContainer.test(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await createTestPreferences(stored),
          ),
          splashDurationProvider.overrideWithValue(Duration.zero),
          if (auth != null) authRepositoryProvider.overrideWithValue(auth),
        ],
      );
      return (container..listen(splashDestinationProvider, (_, _) {})).read(
        splashDestinationProvider.future,
      );
    }

    test('goes to onboarding on first launch', () async {
      expect(await destination({}), AppRoute.onboarding);
    });

    test('skips onboarding once it has been completed', () async {
      expect(
        await destination({PreferenceKeys.onboardingCompleted: true}),
        AppRoute.login,
      );
    });

    test('goes Home when a session was restored', () async {
      expect(
        await destination({
          PreferenceKeys.onboardingCompleted: true,
        }, auth: FakeAuthRepository(signedIn: true)),
        AppRoute.home,
      );
    });

    test('signs out a user who chose not to stay signed in', () async {
      final auth = FakeAuthRepository(signedIn: true);

      final route = await destination({
        PreferenceKeys.onboardingCompleted: true,
        PreferenceKeys.keepSignedIn: false,
      }, auth: auth);

      expect(route, AppRoute.login);
      expect(auth.currentUser, isNull);
    });
  });
}
