import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/connectivity/connectivity.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_preferences.dart';

void main() {
  testWidgets('shows while offline and hides when back online', (
    tester,
  ) async {
    final preferences = await createTestPreferences({
      PreferenceKeys.onboardingCompleted: true,
    });
    final online = StreamController<bool>();
    addTearDown(online.close);
    tester.useScreen(designSize);
    await tester.pumpFullApp(
      preferences,
      auth: FakeAuthRepository(latency: Duration.zero, signedIn: true),
      overrides: [watchOnlineProvider.overrideWithValue(() => online.stream)],
    );
    await tester.pumpAndSettle();
    final banner = find.textContaining('You’re offline');

    online.add(true);
    await tester.pumpAndSettle();
    expect(banner, findsNothing);

    online.add(false);
    await tester.pumpAndSettle();
    expect(banner, findsOneWidget);
    // Above the screens' Material: no "missing Material" underline.
    final text = tester.widget<RichText>(
      find.descendant(of: banner, matching: find.byType(RichText)),
    );
    expect(text.text.style?.decoration, TextDecoration.none);

    online.add(true);
    await tester.pumpAndSettle();
    expect(banner, findsNothing);
  });
}
