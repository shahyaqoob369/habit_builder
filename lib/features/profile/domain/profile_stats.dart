import 'package:flutter/foundation.dart';
import 'package:habit_builder/core/time/date_only.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_stats.dart';

/// The profile's period choice (Figma "This week").
enum ProfilePeriod { thisWeek, lastWeek }

/// One day's progress ring: habits done out of habits due.
@immutable
class DayProgress {
  const DayProgress({required this.day, required this.done, required this.due});

  final DateTime day;
  final int done;
  final int due;

  /// 0–1; a day with nothing due counts as complete only if something was
  /// done anyway.
  double get ratio => due == 0 ? (done > 0 ? 1 : 0) : (done / due).clamp(0, 1);
}

/// The numbers on the profile screen.
@immutable
class ProfileStats {
  const ProfileStats({
    required this.days,
    required this.tasksCompleted,
    required this.perfectDays,
    required this.longestStreak,
    required this.longestStreakHabit,
  });

  /// Seven days of [period] ending [today] (this week) or a week earlier.
  factory ProfileStats.of(
    List<Habit> habits,
    DateTime today,
    ProfilePeriod period,
  ) {
    final end = today.dateOnly.subtract(
      Duration(days: period == ProfilePeriod.lastWeek ? 7 : 0),
    );
    final days = [
      for (var i = 6; i >= 0; i--)
        () {
          final day = DateTime(end.year, end.month, end.day - i);
          var done = 0;
          var due = 0;
          for (final habit in habits) {
            if (day.isBefore(habit.createdAt.dateOnly)) continue;
            if (habit.isDueOn(day)) due++;
            if (habit.statusOn(day) == DayStatus.done) done++;
          }
          return DayProgress(day: day, done: done, due: due);
        }(),
    ];

    Habit? best;
    var longest = 0;
    for (final habit in habits) {
      final streak = HabitStats.of(habit, today).longestStreak;
      if (streak > longest) {
        longest = streak;
        best = habit;
      }
    }

    return ProfileStats(
      days: days,
      tasksCompleted: days.fold(0, (sum, d) => sum + d.done),
      perfectDays: days.where((d) => d.due > 0 && d.done >= d.due).length,
      longestStreak: longest,
      longestStreakHabit: best,
    );
  }

  final List<DayProgress> days;

  /// Habit days marked done in the period.
  final int tasksCompleted;

  /// Days in the period with every due habit done (replaces the design's
  /// "Total Work Hours", owner question Q3).
  final int perfectDays;

  /// The longest streak of any habit, ever.
  final int longestStreak;
  final Habit? longestStreakHabit;
}
