import 'package:flutter/foundation.dart';
import 'package:habit_builder/core/time/date_only.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

/// The numbers on the habit detail screen (Figma "Analytics").
///
/// Only days the habit is due count. Today counts once it is marked, so an
/// unmarked today never breaks a streak or lowers the rate.
@immutable
class HabitStats {
  const HabitStats({
    required this.longestStreak,
    required this.currentStreak,
    required this.completionRate,
    required this.averageEasiness,
  });

  factory HabitStats.of(Habit habit, DateTime today) {
    final end = today.dateOnly;
    final start = habit.createdAt.dateOnly;
    final dueDays = <DateTime>[
      for (
        var day = start;
        !day.isAfter(end);
        day = DateTime(day.year, day.month, day.day + 1)
      )
        if (habit.isDueOn(day) &&
            (!day.isSameDay(end) || habit.statusOn(day) != null))
          day,
    ];

    var longest = 0;
    var run = 0;
    var done = 0;
    for (final day in dueDays) {
      if (habit.statusOn(day) == DayStatus.done) {
        done++;
        run++;
        if (run > longest) longest = run;
      } else {
        run = 0;
      }
    }

    final scores = habit.easiness.values;
    return HabitStats(
      longestStreak: longest,
      currentStreak: run,
      completionRate: dueDays.isEmpty ? 0 : done / dueDays.length,
      averageEasiness: scores.isEmpty
          ? null
          : scores.reduce((a, b) => a + b) / scores.length,
    );
  }

  /// Most due days done in a row.
  final int longestStreak;

  /// Due days done in a row, up to today.
  final int currentStreak;

  /// Done due days out of all due days so far, 0–1.
  final double completionRate;

  /// Mean easiness rating, or null before the first rating.
  final double? averageEasiness;
}

/// Streak lengths that earn the congratulation popup (owner question Q12).
const streakMilestones = {7, 21, 30, 66, 100};
