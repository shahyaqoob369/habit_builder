import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/application/habit_actions.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

void main() {
  final today = DateTime(2026, 10, 20);

  Future<(FakeHabitRepository, Habit)> setUpHabit(int doneDaysBefore) async {
    final repository = FakeHabitRepository(seed: false);
    final habit = await repository.addHabit(
      Habit(
        id: '',
        name: 'Read',
        color: HabitColor.orange,
        createdAt: today.subtract(const Duration(days: 40)),
        log: {
          for (var i = 1; i <= doneDaysBefore; i++)
            today.subtract(Duration(days: i)): DayStatus.done,
        },
      ),
    );
    return (repository, habit);
  }

  group('HabitActions', () {
    test('completing the 7th day in a row reaches a milestone', () async {
      final (repository, habit) = await setUpHabit(6);

      final result = await HabitActions(repository).complete(habit, today);

      expect(result.milestone, 7);
      expect(
        (await repository.watchHabits().first).single.statusOn(today),
        DayStatus.done,
      );
    });

    test('other days are not milestones', () async {
      final (repository, habit) = await setUpHabit(3);

      final result = await HabitActions(repository).complete(habit, today);

      expect(result.milestone, isNull);
    });

    test('rates and misses days', () async {
      final (repository, habit) = await setUpHabit(0);
      final actions = HabitActions(repository);

      await actions.rate(habit, today, 8);
      await actions.miss(habit, today);

      final saved = (await repository.watchHabits().first).single;
      expect(saved.easiness.values, [8]);
      expect(saved.statusOn(today), DayStatus.missed);
    });
  });
}
