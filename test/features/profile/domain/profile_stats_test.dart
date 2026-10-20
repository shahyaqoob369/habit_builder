import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/profile/domain/profile_stats.dart';

void main() {
  final today = DateTime(2026, 10, 20);
  DateTime day(int d) => DateTime(2026, 10, d);

  Habit habit(String id, Map<int, DayStatus> marks) => Habit(
    id: id,
    name: id,
    color: HabitColor.orange,
    createdAt: day(1),
    log: {for (final e in marks.entries) day(e.key): e.value},
  );

  const done = DayStatus.done;

  group('ProfileStats', () {
    final habits = [
      habit('read', {14: done, 15: done, 16: done, 20: done}),
      habit('run', {14: done, 18: done, 19: done}),
    ];

    test('counts this week: rings, tasks and perfect days', () {
      final stats = ProfileStats.of(habits, today, ProfilePeriod.thisWeek);

      expect(stats.days.map((d) => d.day.day), [14, 15, 16, 17, 18, 19, 20]);
      expect(stats.days.map((d) => d.done), [2, 1, 1, 0, 1, 1, 1]);
      expect(stats.days.first.ratio, 1);
      expect(stats.days[1].ratio, 0.5);
      expect(stats.tasksCompleted, 7);
      expect(stats.perfectDays, 1); // Oct 14 only
    });

    test('last week is the seven days before', () {
      final stats = ProfileStats.of(habits, today, ProfilePeriod.lastWeek);

      expect(stats.days.first.day, day(7));
      expect(stats.days.last.day, day(13));
      expect(stats.tasksCompleted, 0);
    });

    test('finds the habit with the longest streak', () {
      final stats = ProfileStats.of(habits, today, ProfilePeriod.thisWeek);

      expect(stats.longestStreak, 3);
      expect(stats.longestStreakHabit?.id, 'read');
    });
  });
}
