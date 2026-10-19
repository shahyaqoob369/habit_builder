import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/auth/presentation/reset_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('ResetPasswordPage', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async {
      preferences = await createTestPreferences({
        PreferenceKeys.onboardingCompleted: true,
      });
    });

    Future<void> openReset(
      WidgetTester tester, {
      Size screen = designSize,
      double textScale = 1,
    }) async {
      tester.useScreen(screen, textScale: textScale);
      await tester.pumpFullApp(preferences);
      await tester.pumpAndSettle();
      await tester.scrollPageTo(find.text('Forgot Password?'));
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordPage), findsOneWidget);
    }

    final email = find.descendant(
      of: find.byType(AppTextField),
      matching: find.byType(EditableText),
    );

    testWidgets('lays out the card as in Figma (below a 44 pt status bar)', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(top: 44 * 3);
      await openReset(tester);

      expect(tester.getTopLeft(find.text('FORGOT YOUR PASSWORD?')).dy, 120);
      expect(tester.getTopLeft(email).dy, 594 + 20);
      expect(tester.getTopLeft(find.text('Send Reset Link')).dy, 682);
    });

    testWidgets('needs a valid email', (tester) async {
      await openReset(tester);

      await tester.enterText(email, 'mira');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('sends the link, then returns to Login with a note', (
      tester,
    ) async {
      await openReset(tester);

      await tester.enterText(email, 'mira@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(ResetPasswordPage), findsNothing);
      expect(
        find.text(
          'If an account exists for mira@example.com, a reset link is on its '
          'way.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the back button and Login both return to Login', (
      tester,
    ) async {
      await openReset(tester);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordPage), findsNothing);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remember password? Login'));
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordPage), findsNothing);
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('fits a small phone with large text (scrolls, no overflow)', (
      tester,
    ) async {
      await openReset(tester, screen: smallPhoneSize, textScale: 1.3);

      await tester.scrollPageTo(find.text('Remember password? Login'));
      expect(find.text('Remember password? Login'), findsOneWidget);
    });
  });
}
