import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';

import '../../../helpers/test_preferences.dart';

void main() {
  group('splashDestinationProvider', () {
    Future<AppRoute> destination(Map<String, Object> stored) async {
      final container = ProviderContainer.test(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await createTestPreferences(stored),
          ),
          splashDurationProvider.overrideWithValue(Duration.zero),
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
  });
}
