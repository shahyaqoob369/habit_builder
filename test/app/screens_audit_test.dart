import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/router/app_router.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/premium/data/fake_premium_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_preferences.dart';

/// Every screen, signed in or out.
const _signedOut = [
  '/onboarding',
  '/login',
  '/login/sign-up',
  '/login/reset-password',
];
const _signedIn = [
  '/home',
  '/home/new-habit',
  '/home/habit/read',
  '/home/habit/read/edit',
  '/courses',
  '/courses/course/journal-challenge',
  '/community',
  '/community/post/post-1',
  '/settings',
  '/settings/profile',
  '/settings/notifications',
  '/settings/customize',
  '/premium',
];

void main() {
  late SharedPreferencesWithCache preferences;

  setUp(() async {
    preferences = await createTestPreferences({
      PreferenceKeys.onboardingCompleted: true,
    });
  });

  Future<void> open(
    WidgetTester tester,
    String path, {
    required bool signedIn,
    required Size size,
    double textScale = 1,
  }) async {
    tester.useScreen(size, textScale: textScale);
    await tester.pumpFullApp(
      preferences,
      auth: FakeAuthRepository(latency: Duration.zero, signedIn: signedIn),
      overrides: [
        premiumRepositoryProvider.overrideWithValue(
          FakePremiumRepository(latency: Duration.zero),
        ),
      ],
    );
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(appRouterProvider).go(path);
    // Not pumpAndSettle: the paywall's countdown never settles.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  for (final (signedIn, paths) in [(false, _signedOut), (true, _signedIn)]) {
    for (final path in paths) {
      group(path, () {
        testWidgets('fits a small phone with larger text', (tester) async {
          await open(
            tester,
            path,
            signedIn: signedIn,
            size: smallPhoneSize,
            textScale: 2,
          );
          expect(tester.takeException(), isNull);
        });

        testWidgets('meets the accessibility guidelines', (tester) async {
          final semantics = tester.ensureSemantics();
          await open(tester, path, signedIn: signedIn, size: designSize);
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          semantics.dispose();
        });
      });
    }
  }
}
