import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/community/presentation/community_page.dart';
import 'package:habit_builder/features/courses/presentation/courses_page.dart';
import 'package:habit_builder/features/habits/presentation/new_habit_page.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:habit_builder/features/premium/data/fake_premium_repository.dart';
import 'package:habit_builder/features/premium/presentation/premium_page.dart';
import 'package:habit_builder/features/settings/presentation/settings_page.dart';
import 'package:habit_builder/features/shell/presentation/widgets/app_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('AppShell', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async {
      preferences = await createTestPreferences({
        PreferenceKeys.onboardingCompleted: true,
      });
    });

    /// Signs in with Google from Login, which lands on Home.
    Future<void> openHome(WidgetTester tester) async {
      tester.useScreen(designSize);
      await tester.pumpFullApp(
        preferences,
        auth: FakeAuthRepository(latency: Duration.zero),
        // The four sample habits are over the free limit.
        overrides: [
          premiumRepositoryProvider.overrideWithValue(
            FakePremiumRepository(latency: Duration.zero, premium: true),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    }

    Finder tab(String label) => find.bySemanticsLabel(label);

    testWidgets('puts the bar at the bottom with the button in the notch', (
      tester,
    ) async {
      await openHome(tester);

      final bar = tester.getRect(find.byType(AppBottomBar));
      // Figma: button top at y 772 on an 896 pt screen (no home indicator
      // in tests, so the bar is the design's 80 pt).
      expect(bar.top, 896 - AppBottomBar.heightFor(0));
      expect(bar.top, 772);
    });

    testWidgets('the tabs switch between the four sections', (tester) async {
      await openHome(tester);

      await tester.tap(tab('Courses'));
      await tester.pumpAndSettle();
      expect(find.byType(CoursesPage), findsOneWidget);

      await tester.tap(tab('Community'));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityPage), findsOneWidget);

      await tester.tap(tab('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(tab('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('marks only the current tab as selected', (tester) async {
      await openHome(tester);

      expect(
        tester.getSemantics(tab('Home')),
        matchesSemantics(
          label: 'Home',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
      expect(
        tester.getSemantics(tab('Courses')),
        matchesSemantics(
          label: 'Courses',
          isButton: true,
          hasSelectedState: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('the center button opens New Habit; Back returns', (
      tester,
    ) async {
      await openHome(tester);

      await tester.tap(find.bySemanticsLabel('New habit'));
      await tester.pumpAndSettle();
      expect(find.byType(NewHabitPage), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(NewHabitPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('the menu opens the side menu, which can switch tabs', (
      tester,
    ) async {
      await openHome(tester);

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text('google.user@example.com'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Courses'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      expect(find.byType(CoursesPage), findsOneWidget);
    });

    testWidgets('signing out from the menu returns to Login', (tester) async {
      await openHome(tester);

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('a free user at the habit limit gets the paywall', (
      tester,
    ) async {
      tester.useScreen(designSize);
      await tester.pumpFullApp(
        preferences,
        auth: FakeAuthRepository(latency: Duration.zero),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('New habit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PremiumPage), findsOneWidget);
      expect(
        find.text(
          'The free plan includes 3 habits. Go Premium for unlimited habits.',
        ),
        findsOneWidget,
      );
    });
  });
}
