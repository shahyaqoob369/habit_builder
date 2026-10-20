import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/core/widgets/app_checkbox.dart';
import 'package:habit_builder/core/widgets/app_text_field.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/auth/presentation/sign_up_page.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('SignUpPage', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async {
      preferences = await createTestPreferences({
        PreferenceKeys.onboardingCompleted: true,
      });
    });

    Future<void> openSignUp(
      WidgetTester tester, {
      Size screen = designSize,
      double textScale = 1,
    }) async {
      tester.useScreen(screen, textScale: textScale);
      await tester.pumpFullApp(preferences);
      await tester.pumpAndSettle();
      await tester.scrollPageTo(find.text('Don’t have an account? Sign up'));
      await tester.tap(find.text('Don’t have an account? Sign up'));
      await tester.pumpAndSettle();
      expect(find.byType(SignUpPage), findsOneWidget);
    }

    Finder field(String hint) => find.descendant(
      of: find.widgetWithText(AppTextField, hint),
      matching: find.byType(EditableText),
    );

    Future<void> fill(
      WidgetTester tester, {
      String name = 'Mira',
      String email = 'mira@example.com',
      String password = 'secret123',
    }) async {
      await tester.enterText(field('Name'), name);
      await tester.enterText(field('Email'), email);
      await tester.enterText(field('Password'), password);
    }

    testWidgets('lays out the form as in Figma (below a 44 pt status bar)', (
      tester,
    ) async {
      tester.view.padding = const FakeViewPadding(top: 44 * 3);
      await openSignUp(tester);

      expect(tester.getTopLeft(find.text('CREATE YOUR ACCOUNT')).dy, 269);
      expect(tester.getTopLeft(field('Name')).dy, 333 + 20);
      expect(tester.getTopLeft(find.text('Keep me signed in')).dy, 545);
      expect(tester.getTopLeft(find.text('Create Account')).dy, 658);
      expect(tester.getTopLeft(find.text('Google')).dy, 775);
    });

    testWidgets('keeps the user signed in by default, but never opts them '
        'into marketing', (tester) async {
      await openSignUp(tester);
      AppCheckbox box(String label) =>
          tester.widget(find.widgetWithText(AppCheckbox, label));

      expect(box('Keep me signed in').value, isTrue);
      expect(box('Email me about special pricing and more').value, isFalse);

      await tester.tap(find.text('Email me about special pricing and more'));
      await tester.pump();
      expect(box('Email me about special pricing and more').value, isTrue);
    });

    testWidgets('checks every field before creating the account', (
      tester,
    ) async {
      await openSignUp(tester);

      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      await fill(tester, password: 'short');
      await tester.pump();
      expect(find.text('Use at least 8 characters'), findsOneWidget);
    });

    testWidgets('creates the account and moves on', (tester) async {
      await openSignUp(tester);

      await fill(tester);
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('an email that already has an account shows an error', (
      tester,
    ) async {
      await openSignUp(tester);

      await fill(tester, email: FakeAuthRepository.demoEmail);
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text('An account with this email already exists. Try logging in.'),
        findsOneWidget,
      );
    });

    testWidgets('Sign In returns to Login', (tester) async {
      await openSignUp(tester);

      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(SignUpPage), findsNothing);
    });

    testWidgets('fits a small phone with large text (scrolls, no overflow)', (
      tester,
    ) async {
      await openSignUp(tester, screen: smallPhoneSize, textScale: 1.3);

      await tester.scrollPageTo(find.text('Already have an account? Sign In'));
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });
  });
}
