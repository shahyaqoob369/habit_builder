import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

void main() {
  final habit = Habit(
    id: 'h',
    name: 'Read',
    color: HabitColor.orange,
    createdAt: DateTime(2026),
    weekdays: const {DateTime.monday, DateTime.friday},
  );

  group('Habit', () {
    test('marks and unmarks days, ignoring the time of day', () {
      final marked = habit.withStatus(
        DateTime(2026, 10, 20, 18, 30),
        DayStatus.done,
      );
      expect(marked.statusOn(DateTime(2026, 10, 20)), DayStatus.done);
      expect(marked.statusOn(DateTime(2026, 10, 21)), isNull);

      final cleared = marked.withStatus(DateTime(2026, 10, 20), null);
      expect(cleared.statusOn(DateTime(2026, 10, 20)), isNull);
      expect(habit.log, isEmpty, reason: 'the original is unchanged');
    });

    test('is due only on its weekdays', () {
      expect(habit.isDueOn(DateTime(2026, 10, 19)), isTrue); // Monday
      expect(habit.isDueOn(DateTime(2026, 10, 20)), isFalse); // Tuesday
    });
  });

  test('DayStatus.cycle goes not marked → done → missed → not marked', () {
    expect(DayStatus.cycle(null), DayStatus.done);
    expect(DayStatus.cycle(DayStatus.done), DayStatus.missed);
    expect(DayStatus.cycle(DayStatus.missed), isNull);
  });

  test('ReminderTime orders by time of day and prints as HH:mm', () {
    const early = ReminderTime(6, 5);
    const late = ReminderTime(10, 0);
    expect(early.compareTo(late), isNegative);
    expect(early.toString(), '06:05');
    expect(const ReminderTime(6, 5), early);
  });
}
