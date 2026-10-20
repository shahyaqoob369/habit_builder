import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/auth/data/fake_auth_repository.dart';
import 'package:habit_builder/features/habits/presentation/new_habit_page.dart';
import 'package:habit_builder/features/habits/presentation/sheets/reminders_sheet.dart';
import 'package:habit_builder/features/habits/presentation/sheets/time_picker_sheet.dart';
import 'package:habit_builder/features/home/presentation/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_preferences.dart';

void main() {
  group('NewHabitPage', () {
    late SharedPreferencesWithCache preferences;

    setUp(() async {
      preferences = await createTestPreferences({
        PreferenceKeys.onboardingCompleted: true,
      });
    });

    /// Signs in, then opens New Habit with the center button.
    Future<void> openNewHabit(WidgetTester tester) async {
      tester.useScreen(designSize);
      await tester.pumpFullApp(
        preferences,
        auth: FakeAuthRepository(latency: Duration.zero),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('New habit'));
      await tester.pumpAndSettle();
      expect(find.byType(NewHabitPage), findsOneWidget);
    }

    Finder nameField() => find.descendant(
      of: find.byType(NewHabitPage),
      matching: find.byType(EditableText),
    );

    testWidgets('the center button becomes Save', (tester) async {
      await openNewHabit(tester);

      expect(find.bySemanticsLabel('Save habit'), findsOneWidget);
      expect(find.text('START THIS HABIT'), findsOneWidget);
      expect(find.text('Every day'), findsOneWidget);
      expect(find.text('10:00AM'), findsOneWidget);
    });

    testWidgets('saving without a name asks for one', (tester) async {
      await openNewHabit(tester);

      await tester.tap(find.bySemanticsLabel('Save habit'));
      await tester.pumpAndSettle();

      expect(find.text('Please name your habit'), findsOneWidget);
      expect(find.byType(NewHabitPage), findsOneWidget);
    });

    testWidgets('saves a named habit and shows it on Home', (tester) async {
      await openNewHabit(tester);

      await tester.enterText(nameField(), 'Stretch');
      await tester.tap(find.bySemanticsLabel('Save habit'));
      await tester.pumpAndSettle();

      expect(find.byType(NewHabitPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Stretch'), findsOneWidget);
      expect(find.bySemanticsLabel('New habit'), findsOneWidget);
    });

    testWidgets('tapping a day turns it off; the preset follows', (
      tester,
    ) async {
      await openNewHabit(tester);

      await tester.tap(find.bySemanticsLabel('Saturday'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Sunday'));
      await tester.pump();

      expect(find.text('Weekdays'), findsOneWidget);
    });

    testWidgets('a preset sets the days', (tester) async {
      await openNewHabit(tester);

      await tester.tap(find.text('Every day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekends'));
      await tester.pumpAndSettle();

      expect(find.text('Weekends'), findsOneWidget);
    });

    testWidgets('reminders: toggle a preset time, add a custom one', (
      tester,
    ) async {
      await openNewHabit(tester);

      await tester.tap(find.text('Reminder'));
      await tester.pumpAndSettle();
      expect(find.byType(RemindersSheet), findsOneWidget);

      await tester.tap(find.text('06:00 AM'));
      await tester.pump();
      await tester.tap(find.text('Add Reminder'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerSheet), findsOneWidget);
      await tester.tap(find.text('pm'));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // 06:00 and 10:00 were on; 09:00 PM is added at the end.
      expect(find.text('09:00 PM'), findsOneWidget);
      Navigator.of(tester.element(find.byType(RemindersSheet))).pop();
      await tester.pumpAndSettle();
      expect(find.text('06:00AM +2'), findsOneWidget);
    });
  });
}
