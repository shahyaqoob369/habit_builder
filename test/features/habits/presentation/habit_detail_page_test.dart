import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/habit_detail_page.dart';
import 'package:habit_builder/features/habits/presentation/widgets/month_calendar.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('HabitDetailPage', () {
    final today = DateTime(2026, 10, 20);

    Future<FakeHabitRepository> pumpDetail(
      WidgetTester tester, {
      String id = 'read',
      FakeHabitRepository? repository,
    }) async {
      final repo = repository ?? FakeHabitRepository(today: today);
      tester
        ..useScreen(const Size(414, 1332))
        ..view.padding = const FakeViewPadding(top: 44 * 3);
      await tester.pumpApp(
        HabitDetailPage(habitId: id),
        overrides: [
          todayProvider.overrideWithValue(today),
          habitRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.pump();
      return repo;
    }

    testWidgets('lays out summary, calendar and stats as in Figma', (
      tester,
    ) async {
      await pumpDetail(tester);

      expect(find.text('Read A Book'), findsNWidgets(2));
      expect(find.text('Repeat: Every day'), findsOneWidget);
      expect(find.text('Reminders: 10:00 AM'), findsOneWidget);
      expect(tester.getTopLeft(find.byType(MonthCalendar)).dy, 223);
      expect(find.text('October'), findsOneWidget);
      expect(find.text('2 DAYS'), findsNWidgets(2)); // longest & current
      // The sample habit is already done today.
      expect(find.text('Completed today'), findsOneWidget);
      expect(find.text('Mark Habit as Missed'), findsOneWidget);
    });

    testWidgets('mark complete asks how easy it was, then updates', (
      tester,
    ) async {
      final repo = await pumpDetail(tester, id: 'exercise');

      await tester.tap(find.text('Mark Habit as Complete'));
      await tester.pumpAndSettle();
      expect(find.text('HOW EASY WAS IT?'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('8'),
        ),
      );
      await tester.pumpAndSettle();

      final habit = repo.habits[1];
      expect(habit.statusOn(today), DayStatus.done);
      expect(habit.easiness.values, [8]);
      expect(find.text('Completed today'), findsOneWidget);
    });

    testWidgets('a 7-day streak shows the congratulation popup', (
      tester,
    ) async {
      final repo = FakeHabitRepository(
        habits: [
          Habit(
            id: 'stretch',
            name: 'Stretch',
            color: HabitColor.blue,
            createdAt: DateTime(2026, 10),
            log: {
              for (var d = 14; d < 20; d++)
                DateTime(2026, 10, d): DayStatus.done,
            },
          ),
        ],
      );
      await pumpDetail(tester, id: 'stretch', repository: repo);

      await tester.tap(find.text('Mark Habit as Complete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('CONGRATULATIONS!'), findsOneWidget);
      expect(
        find.text('7 days of Stretch in a row. Keep the streak going!'),
        findsOneWidget,
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('CONGRATULATIONS!'), findsNothing);
    });

    testWidgets('mark missed marks today with a half cell', (tester) async {
      final repo = await pumpDetail(tester, id: 'exercise');

      await tester.tap(find.text('Mark Habit as Missed'));
      await tester.pumpAndSettle();

      final habit = repo.habits[1];
      expect(habit.statusOn(today), DayStatus.missed);
      expect(find.text('Missed today'), findsOneWidget);
    });

    testWidgets('the calendar goes back to earlier months', (tester) async {
      await pumpDetail(tester);

      expect(find.byTooltip('Next month'), findsNothing);
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pump();

      expect(find.text('September'), findsOneWidget);
      expect(find.byTooltip('Next month'), findsOneWidget);
    });

    testWidgets('a deleted habit shows a message', (tester) async {
      await pumpDetail(tester, id: 'gone');

      expect(find.text('HABIT NOT FOUND'), findsOneWidget);
    });
  });
}
