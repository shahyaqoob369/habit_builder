import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/data/habit_mapper.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

void main() {
  group('HabitMapper', () {
    final habit = Habit(
      id: 'h1',
      name: 'Read A Book',
      color: HabitColor.blue,
      icon: HabitIcon.learn,
      createdAt: DateTime(2026, 10, 2),
      weekdays: const {5, 1, 3},
      reminders: const [ReminderTime(7, 30), ReminderTime(21, 5)],
      notificationsEnabled: true,
      log: {
        DateTime(2026, 10, 19): DayStatus.done,
        DateTime(2026, 10, 20): DayStatus.missed,
      },
      easiness: {DateTime(2026, 10, 19): 8},
    );

    test('writes the documented layout', () {
      expect(HabitMapper.toFirestore(habit, sortKey: 42), {
        'name': 'Read A Book',
        'color': 'blue',
        'icon': 'learn',
        'createdAt': '2026-10-02',
        'sortKey': 42,
        'weekdays': [1, 3, 5],
        'reminders': ['07:30', '21:05'],
        'notificationsEnabled': true,
        'log': {'2026-10-19': 'done', '2026-10-20': 'missed'},
        'easiness': {'2026-10-19': 8},
      });
    });

    test('leaves sortKey out unless given (updates keep the old one)', () {
      expect(HabitMapper.toFirestore(habit), isNot(contains('sortKey')));
    });

    test('reads back what it writes', () {
      final read = HabitMapper.fromFirestore(
        'h1',
        HabitMapper.toFirestore(habit),
      );

      expect(read.name, habit.name);
      expect(read.color, habit.color);
      expect(read.icon, habit.icon);
      expect(read.createdAt, habit.createdAt);
      expect(read.weekdays, habit.weekdays);
      expect(read.reminders, habit.reminders);
      expect(read.notificationsEnabled, isTrue);
      expect(read.log, habit.log);
      expect(read.easiness, habit.easiness);
    });

    test('falls back on unknown or broken values', () {
      final read = HabitMapper.fromFirestore('h2', {
        'name': 'Future habit',
        'color': 'ultraviolet',
        'icon': 'hoverboard',
        'createdAt': 'yesterday',
        'weekdays': <Object?>[0, 8, 'mon'],
        'reminders': <Object?>['25:00', '7:5', 9, '06:00'],
        'log': <String, Object?>{
          '2026-10-19': 'done',
          '2026-02-31': 'done',
          'today': 'done',
          '2026-10-20': 'skipped',
        },
        'easiness': <String, Object?>{'2026-10-19': 11, '2026-10-18': 3},
      });

      expect(read.color, HabitColor.orange);
      expect(read.icon, HabitIcon.book);
      expect(read.createdAt, DateTime(2000));
      expect(read.weekdays, Habit.allWeekdays);
      expect(read.reminders, const [ReminderTime(6, 0)]);
      expect(read.log, {DateTime(2026, 10, 19): DayStatus.done});
      expect(read.easiness, {DateTime(2026, 10, 18): 3});
    });

    test('day keys are calendar days, zero padded', () {
      expect(HabitMapper.dayKey(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
      expect(HabitMapper.parseDay('2026-03-07'), DateTime(2026, 3, 7));
      expect(HabitMapper.parseDay('2026-13-01'), isNull);
    });
  });
}
