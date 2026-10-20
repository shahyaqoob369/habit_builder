import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit_stats.dart';

/// What happened after marking a day done.
typedef CompletionResult = ({Habit habit, int? milestone});

/// Day-level actions on a habit, shared by Home and the detail screen.
class HabitActions {
  const HabitActions(this._repository);

  final HabitRepository _repository;

  /// Marks [day] done. Returns the updated habit and, if this completes a
  /// streak milestone (7, 21, 30… days), that streak length.
  Future<CompletionResult> complete(Habit habit, DateTime day) async {
    final updated = habit.withStatus(day, DayStatus.done);
    await _repository.updateHabit(updated);
    final streak = HabitStats.of(updated, day).currentStreak;
    final reached =
        habit.statusOn(day) != DayStatus.done &&
        streakMilestones.contains(streak);
    return (habit: updated, milestone: reached ? streak : null);
  }

  Future<void> miss(Habit habit, DateTime day) =>
      _repository.setStatus(habit.id, day, DayStatus.missed);

  /// Saves how easy [day] felt (1–10).
  Future<void> rate(Habit habit, DateTime day, int score) =>
      _repository.updateHabit(habit.withEasiness(day, score));
}

final habitActionsProvider = Provider<HabitActions>(
  (ref) => HabitActions(ref.watch(habitRepositoryProvider)),
);
