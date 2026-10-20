import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/domain/auth_repository.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/auth/presentation/reset_password_page.dart';
import 'package:habit_builder/features/auth/presentation/sign_up_page.dart';
import 'package:habit_builder/features/auth/presentation/widgets/email_login_panel.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('LoginPage', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async {
      preferences = await createTestPreferences({
        PreferenceKeys.onboardingCompleted: true,
      });
    });

    Future<void> openLogin(
      WidgetTester tester, {
      Size screen = designSize,
      double textScale = 1,
      AuthRepository? auth,
    }) async {
      tester.useScreen(screen, textScale: textScale);
      await tester.pumpFullApp(preferences, auth: auth);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    }

    Finder field(String hint) => find.descendant(
      of: find.widgetWithText(AppTextField, hint),
      matching: find.byType(EditableText),
    );

    Future<void> logIn(WidgetTester tester, String email, String password) {
      return tester
          .enterText(field('Email'), email)
          .then((_) => tester.enterText(field('Password'), password))
          .then((_) => tester.tap(find.text('Login')));
    }

    testWidgets('lays out the welcome and the panel as in Figma', (
      tester,
    ) async {
      await openLogin(tester);

      expect(tester.getTopLeft(find.byType(EmailLoginPanel)).dy, 540);
      expect(tester.getTopLeft(find.text('Continue with Google')).dy, 424);
      expect(tester.getTopLeft(field('Email')).dy, 604 + 20);
      expect(tester.getTopLeft(find.text('Login')).dy, 767);
    });

    testWidgets('submitting an empty form shows what is missing', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      await tester.enterText(field('Email'), 'mira');
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('a wrong password shows an error and stays', (tester) async {
      await openLogin(tester);

      await logIn(tester, FakeAuthRepository.demoEmail, 'wrong');
      await tester.pumpAndSettle();

      expect(
        find.text('That email and password don’t match. Please try again.'),
        findsOneWidget,
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('shows a spinner while logging in, then moves on', (
      tester,
    ) async {
      await openLogin(
        tester,
        auth: FakeAuthRepository(latency: const Duration(seconds: 1)),
      );

      await logIn(
        tester,
        FakeAuthRepository.demoEmail,
        FakeAuthRepository.demoPassword,
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Continue with Google signs in', (tester) async {
      await openLogin(tester);

      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Forgot Password? opens Reset Password; Back returns', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ResetPasswordPage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Sign up opens Sign Up', (tester) async {
      await openLogin(tester);

      await tester.tap(find.text('Don’t have an account? Sign up'));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpPage), findsOneWidget);
    });

    testWidgets('the help button explains the options', (tester) async {
      await openLogin(tester);

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();
      expect(find.text('NEED A HAND?'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
      expect(find.text('NEED A HAND?'), findsNothing);
    });

    testWidgets('fits a small phone with large text (scrolls, no overflow)', (
      tester,
    ) async {
      await openLogin(tester, screen: smallPhoneSize, textScale: 1.3);

      await tester.scrollPageTo(find.text('Login'));
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
