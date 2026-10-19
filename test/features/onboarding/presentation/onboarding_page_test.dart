import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/onboarding/presentation/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('OnboardingPage', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async => preferences = await createTestPreferences());

    Future<void> openOnboarding(WidgetTester tester) async {
      await tester.pumpFullApp(preferences);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);
    }

    testWidgets('starts on the welcome page with Skip, dots and Next', (
      tester,
    ) async {
      await openOnboarding(tester);

      expect(find.text('WELCOME TO\nMONUMENTAL HABITS'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.bySemanticsLabel('Page 1 of 4'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('Next walks to the last page, which shows Get Started', (
      tester,
    ) async {
      await openOnboarding(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('CREATE NEW\nHABIT EASILY'), findsOneWidget);
      expect(find.bySemanticsLabel('Page 2 of 4'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('JOIN A SUPPORTIVE\nCOMMUNITY'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('Get Started completes onboarding and leaves it', (
      tester,
    ) async {
      await openOnboarding(tester);
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(preferences.getBool(PreferenceKeys.onboardingCompleted), isTrue);
    });

    testWidgets('Skip completes onboarding and leaves it', (tester) async {
      await openOnboarding(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(preferences.getBool(PreferenceKeys.onboardingCompleted), isTrue);
    });

    testWidgets('system back returns to the previous page', (tester) async {
      await openOnboarding(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('WELCOME TO\nMONUMENTAL HABITS'), findsOneWidget);
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('pages can be swiped', (tester) async {
      await openOnboarding(tester);

      await tester.fling(
        find.text('WELCOME TO\nMONUMENTAL HABITS'),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('CREATE NEW\nHABIT EASILY'), findsOneWidget);
    });
  });
}
