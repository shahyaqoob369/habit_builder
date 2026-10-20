import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/profile/presentation/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('ProfilePage', () {
    late SharedPreferencesWithCache preferences;
    late FakeAuthRepository auth;

    setUp(() async {
      preferences = await createTestPreferences({
        PreferenceKeys.onboardingCompleted: true,
      });
      auth = FakeAuthRepository(latency: Duration.zero);
    });

    /// Logs in as the demo user, then opens the profile from Home's avatar.
    Future<void> openProfile(WidgetTester tester) async {
      tester.useScreen(designSize);
      await tester.pumpFullApp(preferences, auth: auth);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(EditableText).first,
        FakeAuthRepository.demoEmail,
      );
      await tester.enterText(
        find.byType(EditableText).last,
        FakeAuthRepository.demoPassword,
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
    }

    testWidgets("shows the user, this week's numbers and rings", (
      tester,
    ) async {
      await openProfile(tester);

      expect(find.text('Demo'), findsOneWidget);
      expect(find.text(FakeAuthRepository.demoEmail), findsOneWidget);
      expect(find.text('Perfect Days'), findsOneWidget);
      expect(find.text('Tasks Completed'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
    });

    testWidgets('the name can be edited', (tester) async {
      await openProfile(tester);

      await tester.tap(find.byTooltip('Edit profile'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.byType(EditableText),
        ),
        'Mira',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Mira'), findsOneWidget);
    });

    testWidgets('switching to last week', (tester) async {
      await openProfile(tester);

      await tester.tap(find.text('This week'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last week'));
      await tester.pumpAndSettle();

      expect(find.text('Last week'), findsOneWidget);
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('deleting the account asks first, then signs out', (
      tester,
    ) async {
      await openProfile(tester);

      await tester.scrollUntilVisible(find.text('Delete account'), 100);
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('DELETE YOUR ACCOUNT?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(auth.currentUser, isNull);
    });
  });
}
