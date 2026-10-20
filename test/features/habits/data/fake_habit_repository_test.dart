import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

void main() {
  final today = DateTime(2026, 10, 20);

  group('FakeHabitRepository', () {
    test(
      "starts with the design's four habits, history ending today",
      () async {
        final habits = await FakeHabitRepository(
          today: today,
        ).watchHabits().first;

        expect(habits.map((h) => h.name), [
          'Read A Book',
          'Exercise',
          'Wake Up Early',
          'Walk Dog',
        ]);
        final read = habits.first;
        expect(read.statusOn(today), DayStatus.done);
        expect(read.statusOn(DateTime(2026, 10, 18)), DayStatus.missed);
        expect(habits[1].statusOn(today), isNull);
      },
    );

    test('emits every change', () async {
      final repo = FakeHabitRepository(today: today);
      final updates = repo.watchHabits().skip(1);
      final next = updates.first;

      await repo.setStatus('exercise', today, DayStatus.done);

      expect((await next)[1].statusOn(today), DayStatus.done);
    });

    test('adds and deletes habits', () async {
      final repo = FakeHabitRepository(seed: false);
      final added = await repo.addHabit(
        Habit(
          id: '',
          name: 'Stretch',
          color: HabitColor.blue,
          createdAt: today,
        ),
      );
      expect(added.id, isNotEmpty);
      expect(await repo.watchHabits().first, [added]);

      await repo.deleteHabit(added.id);
      expect(await repo.watchHabits().first, isEmpty);
    });
  });
}
