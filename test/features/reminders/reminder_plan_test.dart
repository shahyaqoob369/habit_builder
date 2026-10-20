import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/reminders/data/reminder_scheduler.dart';
import 'package:habit_builder/features/reminders/domain/reminder_plan.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Habit _habit(
  String id, {
  Set<int> weekdays = Habit.allWeekdays,
  List<ReminderTime> reminders = const [ReminderTime(8, 0)],
  bool notifications = true,
}) => Habit(
  id: id,
  name: 'Habit $id',
  color: HabitColor.orange,
  createdAt: DateTime(2026, 10),
  weekdays: weekdays,
  reminders: reminders,
  notificationsEnabled: notifications,
);

void main() {
  tz_data.initializeTimeZones();

  group('planReminders', () {
    List<PlannedReminder> plan(List<Habit> habits, {bool enabled = true}) =>
        planReminders(habits, enabled: enabled, body: 'Go!');

    test('nothing when the Settings switch is off', () {
      expect(plan([_habit('a')], enabled: false), isEmpty);
    });

    test('skips habits with notifications off', () {
      expect(plan([_habit('a', notifications: false)]), isEmpty);
    });

    test('an every-day habit gets one daily reminder per time', () {
      final reminders = plan([
        _habit(
          'a',
          reminders: const [ReminderTime(7, 0), ReminderTime(21, 30)],
        ),
      ]);

      expect(reminders.map((r) => (r.weekday, r.time)), [
        (null, const ReminderTime(7, 0)),
        (null, const ReminderTime(21, 30)),
      ]);
      expect(reminders.first.title, 'Habit a');
      expect(reminders.first.body, 'Go!');
      expect(reminders.first.habitId, 'a');
    });

    test('other habits get a weekly reminder on each due day', () {
      final reminders = plan([
        _habit('a', weekdays: {5, 1, 3}),
      ]);

      expect(reminders.map((r) => r.weekday), [1, 3, 5]);
      expect(reminders.map((r) => r.id).toSet(), hasLength(3));
    });

    test('stops at the iOS limit of 64', () {
      final habits = [
        for (var i = 0; i < 20; i++) _habit('$i', weekdays: {1, 2, 3, 4, 5}),
      ];

      expect(plan(habits), hasLength(maxPlannedReminders));
    });
  });

  group('LocalReminderScheduler.nextOccurrence', () {
    final zone = tz.getLocation('Asia/Karachi');
    // Tuesday 20 October 2026, 09:00 local.
    final now = tz.TZDateTime(zone, 2026, 10, 20, 9);
    PlannedReminder at(int hour, {int? weekday}) => PlannedReminder(
      id: 1,
      habitId: 'a',
      title: 't',
      body: 'b',
      time: ReminderTime(hour, 0),
      weekday: weekday,
    );

    test('later today', () {
      expect(
        LocalReminderScheduler.nextOccurrence(at(10), now),
        tz.TZDateTime(zone, 2026, 10, 20, 10),
      );
    });

    test('tomorrow once today’s time has passed', () {
      expect(
        LocalReminderScheduler.nextOccurrence(at(8), now),
        tz.TZDateTime(zone, 2026, 10, 21, 8),
      );
    });

    test('the next matching weekday', () {
      // Monday → next Monday, 26 October.
      expect(
        LocalReminderScheduler.nextOccurrence(at(8, weekday: 1), now),
        tz.TZDateTime(zone, 2026, 10, 26, 8),
      );
    });
  });
}
