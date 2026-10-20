// Drives the real app, against the real Firebase project, on a simulator:
//   flutter test integration_test/app_flow_test.dart -d <device id>
// Signs up a throwaway account through the UI and deletes it at the end.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/app/app.dart';
import 'package:habit_builder/app/firebase_backend.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/presentation/login_page.dart';
import 'package:habit_builder/features/auth/presentation/sign_up_page.dart';
import 'package:habit_builder/features/habits/data/habit_mapper.dart';
import 'package:habit_builder/features/habits/presentation/habit_detail_page.dart';
import 'package:habit_builder/features/habits/presentation/new_habit_page.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:habit_builder/features/profile/presentation/profile_page.dart';
import 'package:habit_builder/features/splash/application/splash_controller.dart';
import 'package:habit_builder/firebase_options.dart';
import 'package:integration_test/integration_test.dart';

extension on WidgetTester {
  /// Scrolls [page]'s list to the end, clear of the bottom bar that
  /// overlaps the bottom of the screen.
  Future<void> scrollToEnd(Finder page) async {
    final scrollable = find
        .descendant(of: page, matching: find.byType(Scrollable))
        .first;
    final position = state<ScrollableState>(scrollable).position;
    position.jumpTo(position.maxScrollExtent);
    await pumpAndSettle();
  }

  /// Pumps until [condition] holds.
  Future<void> pumpUntilTrue(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(end)) throw TestFailure('Timed out');
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Pumps until [finder] shows (network calls aren't animations, so
  /// pumpAndSettle doesn't wait for them).
  Future<void> pumpUntil(
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final end = DateTime.now().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(end)) {
        final texts = find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data)
            .nonNulls
            .join(' | ');
        throw TestFailure('Timed out waiting for $finder. Showing: $texts');
      }
      await pump(const Duration(milliseconds: 100));
    }
  }

  /// Types into the field with [hint] on [page].
  Future<void> enterField(Finder page, String hint, String text) => enterText(
    find.descendant(of: page, matching: find.widgetWithText(TextField, hint)),
    text,
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(
    () => Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  );

  testWidgets('sign up, add a habit, complete it, delete the account', (
    tester,
  ) async {
    await FirebaseAuth.instance.signOut();
    final preferences = await createPreferences();
    await preferences.clear();
    final analytics = RecordingAnalytics();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          splashDurationProvider.overrideWithValue(Duration.zero),
          analyticsProvider.overrideWithValue(analytics),
          ...firebaseOverrides(),
        ],
        child: const App(),
      ),
    );

    // First launch: onboarding, then login, then sign up.
    await tester.pumpUntil(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pumpUntil(find.byType(LoginPage));
    await tester.ensureVisible(find.text('Don’t have an account? Sign up'));
    await tester.tap(find.text('Don’t have an account? Sign up'));
    await tester.pumpUntil(find.byType(SignUpPage));
    await tester.pumpAndSettle();
    final signUp = find.byType(SignUpPage);

    // Whatever happens, don't leave the throwaway account behind.
    addTearDown(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users/${user.uid}/habits')
          .get()
          .then(
            (page) => Future.wait(page.docs.map((d) => d.reference.delete())),
          );
      await FirebaseFirestore.instance.doc('users/${user.uid}').delete();
      await user.delete();
    });
    const password = 'Integration-test-1';
    final email =
        'integration-${DateTime.now().millisecondsSinceEpoch}@example.com';
    await tester.enterField(signUp, 'Name', 'Flow Test');
    await tester.enterField(signUp, 'Email', email);
    await tester.enterField(signUp, 'Password', password);
    // Close the keyboard so it doesn't cover the button.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));

    // A new account starts with no habits.
    await tester.pumpUntil(find.text('NO HABITS YET'));
    expect(find.byType(HomePage), findsOneWidget);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Add a habit with the center button.
    await tester.tap(find.bySemanticsLabel('New habit'));
    await tester.pumpUntil(find.byType(NewHabitPage));
    await tester.enterText(
      find
          .descendant(
            of: find.byType(NewHabitPage),
            matching: find.byType(EditableText),
          )
          .first,
      'Drink Water',
    );
    await tester.tap(find.bySemanticsLabel('Save habit'));
    // (The editor's field also says "Drink Water", so look inside Home.)
    final onHome = find.descendant(
      of: find.byType(HomePage),
      matching: find.text('Drink Water'),
    );
    await tester.pumpUntil(onHome);
    await tester.pumpAndSettle();
    expect(find.byType(NewHabitPage), findsNothing);

    // Complete today from the habit's screen; skip the easiness rating.
    await tester.tap(onHome);
    await tester.pumpUntil(find.byType(HabitDetailPage));
    await tester.pumpAndSettle();
    await tester.scrollToEnd(find.byType(HabitDetailPage));
    await tester.tap(find.text('Mark Habit as Complete'));
    await tester.pumpUntil(find.text('Skip'));
    await tester.tap(find.text('Skip'));
    await tester.pumpUntil(find.text('Completed today'));

    // It's in Firestore, with today marked done.
    await FirebaseFirestore.instance.waitForPendingWrites();
    final habits = await FirebaseFirestore.instance
        .collection('users/$uid/habits')
        .get();
    expect(habits.docs, hasLength(1));
    final habit = habits.docs.single.data();
    expect(habit['name'], 'Drink Water');
    expect(
      (habit['log']! as Map)[HabitMapper.dayKey(DateTime.now())],
      'done',
    );
    // Sign up finishes in the background after Home shows (display name),
    // so its event can come last.
    await tester.pumpUntilTrue(
      () => analytics.events.any((e) => e.name == 'sign_up'),
    );
    expect(
      analytics.events.map((e) => e.name),
      containsAll(['sign_up', 'habit_created', 'habit_completed']),
    );

    // Delete the account from the profile.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpUntil(find.byType(HomePage));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpUntil(find.byType(ProfilePage));
    await tester.pumpAndSettle();
    await tester.scrollToEnd(find.byType(ProfilePage));
    await tester.tap(find.text('Delete account'));
    await tester.pumpUntil(find.byType(AlertDialog));
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(EditableText),
      ),
      password,
    );
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpUntil(find.byType(LoginPage));
    expect(FirebaseAuth.instance.currentUser, isNull);
  });
}
