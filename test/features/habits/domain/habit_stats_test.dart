import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_stats.dart';

void main() {
  final today = DateTime(2026, 10, 20); // Tuesday
  DateTime day(int d) => DateTime(2026, 10, d);

  Habit habit(Map<int, DayStatus> marks, {Set<int>? weekdays}) => Habit(
    id: 'h',
    name: 'Read',
    color: HabitColor.orange,
    createdAt: day(11),
    weekdays: weekdays ?? Habit.allWeekdays,
    log: {for (final e in marks.entries) day(e.key): e.value},
  );

  const done = DayStatus.done;
  const missed = DayStatus.missed;

  group('HabitStats', () {
    test('counts streaks over due days', () {
      final stats = HabitStats.of(
        habit({
          11: done, 12: done, 13: done, 14: missed, //
          15: done, 16: done, 17: done, 18: done, 19: done, 20: done,
        }),
        today,
      );

      expect(stats.longestStreak, 6);
      expect(stats.currentStreak, 6);
      expect(stats.completionRate, closeTo(9 / 10, 1e-9));
    });

    test('an unmarked today neither breaks the streak nor counts', () {
      final stats = HabitStats.of(habit({18: done, 19: done}), today);

      expect(stats.currentStreak, 2);
      // Due days so far: 11–19 (9 days), 2 done.
      expect(stats.completionRate, closeTo(2 / 9, 1e-9));
    });

    test('days the habit is not due are skipped', () {
      // Mondays and Wednesdays only: Oct 12, 14, 19.
      final stats = HabitStats.of(
        habit(
          {12: done, 14: done, 19: done},
          weekdays: {DateTime.monday, DateTime.wednesday},
        ),
        today,
      );

      expect(stats.currentStreak, 3);
      expect(stats.completionRate, 1);
    });

    test('averages the easiness ratings', () {
      final rated = habit({
        19: done,
      }).withEasiness(day(18), 6).withEasiness(day(19), 9);

      expect(HabitStats.of(rated, today).averageEasiness, 7.5);
      expect(HabitStats.of(habit({}), today).averageEasiness, isNull);
    });
  });
}
