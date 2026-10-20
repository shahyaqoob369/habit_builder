import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/analytics/analytics.dart';
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
      final analytics = RecordingAnalytics();

      final result = await HabitActions(
        repository,
        analytics,
      ).complete(habit, today, source: MarkSource.detail);

      expect(result.milestone, 7);
      expect(
        (await repository.watchHabits().first).single.statusOn(today),
        DayStatus.done,
      );
      expect(analytics.events, [
        AnalyticsEvent.habitCompleted(streak: 7, source: 'detail'),
        AnalyticsEvent.streakMilestone(7),
      ]);
    });

    test('other days are not milestones', () async {
      final (repository, habit) = await setUpHabit(3);

      final result = await HabitActions(
        repository,
        RecordingAnalytics(),
      ).complete(habit, today, source: MarkSource.detail);

      expect(result.milestone, isNull);
    });

    test('rates and misses days', () async {
      final (repository, habit) = await setUpHabit(0);
      final analytics = RecordingAnalytics();
      final actions = HabitActions(repository, analytics);

      final done = (await actions.complete(
        habit,
        today,
        source: MarkSource.detail,
      )).habit;
      await actions.rate(done, today, 8);
      var saved = (await repository.watchHabits().first).single;
      expect(saved.easiness.values, [8]);

      // A missed day has no easiness rating.
      await actions.miss(saved, today, source: MarkSource.detail);
      saved = (await repository.watchHabits().first).single;
      expect(saved.easiness, isEmpty);
      expect(saved.statusOn(today), DayStatus.missed);
      expect(analytics.events, [
        AnalyticsEvent.habitCompleted(streak: 1, source: 'detail'),
        AnalyticsEvent.habitRated(8),
        AnalyticsEvent.habitMissed(source: 'detail'),
      ]);
    });

    test('a Home tap cycles done → missed → not marked', () async {
      final (repository, habit) = await setUpHabit(0);
      final analytics = RecordingAnalytics();
      final actions = HabitActions(repository, analytics);
      Future<Habit> saved() async =>
          (await repository.watchHabits().first).single;

      await actions.cycle(habit, today);
      expect((await saved()).statusOn(today), DayStatus.done);
      await actions.cycle(await saved(), today);
      expect((await saved()).statusOn(today), DayStatus.missed);
      await actions.cycle(await saved(), today);
      expect((await saved()).statusOn(today), isNull);

      expect(analytics.events, [
        AnalyticsEvent.habitCompleted(streak: 1, source: 'home'),
        AnalyticsEvent.habitMissed(source: 'home'),
      ]);
    });

    test('logs nothing once the user turns sharing off', () async {
      final (repository, habit) = await setUpHabit(0);
      final analytics = RecordingAnalytics();
      await analytics.setCollectionEnabled(enabled: false);

      await HabitActions(
        repository,
        analytics,
      ).complete(habit, today, source: MarkSource.home);

      expect(analytics.events, isEmpty);
    });
  });
}
