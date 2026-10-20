import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit_stats.dart';

/// What happened after marking a day done.
typedef CompletionResult = ({Habit habit, int? milestone});

/// Where a day was marked, for analytics.
enum MarkSource { home, detail }

/// Day-level actions on a habit, shared by Home and the detail screen.
class HabitActions {
  const HabitActions(this._repository, this._analytics);

  final HabitRepository _repository;
  final Analytics _analytics;

  /// Marks [day] done. Returns the updated habit and, if this completes a
  /// streak milestone (7, 21, 30… days), that streak length.
  Future<CompletionResult> complete(
    Habit habit,
    DateTime day, {
    required MarkSource source,
  }) async {
    final updated = habit.withStatus(day, DayStatus.done);
    await _repository.updateHabit(updated);
    final streak = HabitStats.of(updated, day).currentStreak;
    final wasDone = habit.statusOn(day) == DayStatus.done;
    final reached = !wasDone && streakMilestones.contains(streak);
    if (!wasDone) {
      _log(AnalyticsEvent.habitCompleted(streak: streak, source: source.name));
    }
    if (reached) _log(AnalyticsEvent.streakMilestone(streak));
    return (habit: updated, milestone: reached ? streak : null);
  }

  Future<void> miss(
    Habit habit,
    DateTime day, {
    required MarkSource source,
  }) async {
    await _repository.setStatus(habit.id, day, DayStatus.missed);
    _log(AnalyticsEvent.habitMissed(source: source.name));
  }

  /// Home's cell tap: not marked → done → missed → not marked.
  Future<void> cycle(Habit habit, DateTime day) async {
    switch (DayStatus.cycle(habit.statusOn(day))) {
      case DayStatus.done:
        await complete(habit, day, source: MarkSource.home);
      case DayStatus.missed:
        await miss(habit, day, source: MarkSource.home);
      case null:
        await _repository.setStatus(habit.id, day, null);
    }
  }

  /// Saves how easy [day] felt (1–10).
  Future<void> rate(Habit habit, DateTime day, int score) async {
    await _repository.updateHabit(habit.withEasiness(day, score));
    _log(AnalyticsEvent.habitRated(score));
  }

  void _log(AnalyticsEvent event) => unawaited(_analytics.logEvent(event));
}

final habitActionsProvider = Provider<HabitActions>(
  (ref) => HabitActions(
    ref.watch(habitRepositoryProvider),
    ref.watch(analyticsProvider),
  ),
);
