import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/onboarding/data/onboarding_repository.dart';

import '../../../helpers/test_preferences.dart';

void main() {
  group('OnboardingRepository', () {
    test('is not completed on a fresh install', () async {
      final repository = OnboardingRepository(await createTestPreferences());

      expect(repository.isCompleted, isFalse);
    });

    test('complete() persists the flag', () async {
      final preferences = await createTestPreferences();
      final repository = OnboardingRepository(preferences);

      await repository.complete();

      expect(repository.isCompleted, isTrue);
      expect(preferences.getBool(PreferenceKeys.onboardingCompleted), isTrue);
    });
  });
}
