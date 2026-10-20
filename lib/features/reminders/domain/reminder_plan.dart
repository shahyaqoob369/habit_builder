import 'package:flutter/foundation.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

/// One repeating reminder: every [weekday] (or every day when null) at
/// [time], for habit [habitId].
@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.habitId,
    required this.title,
    required this.body,
    required this.time,
    this.weekday,
  });

  /// Unique within one plan; the scheduler replaces the whole plan.
  final int id;
  final String habitId;
  final String title;
  final String body;
  final ReminderTime time;

  /// [DateTime.weekday] (Monday = 1), or null for every day.
  final int? weekday;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.habitId == habitId &&
      other.title == title &&
      other.body == body &&
      other.time == time &&
      other.weekday == weekday;

  @override
  int get hashCode => Object.hash(id, habitId, title, body, time, weekday);

  @override
  String toString() => 'PlannedReminder($habitId, ${weekday ?? 'daily'} $time)';
}

/// iOS keeps at most 64 pending notifications per app.
const maxPlannedReminders = 64;

/// The reminders to schedule for [habits]: each habit with notifications on
/// gets its reminder times on its due days. An every-day habit needs one
/// daily reminder per time; others one weekly reminder per due day.
///
/// Nothing when [enabled] (the master switch in Settings) is off. At most
/// [maxPlannedReminders], earliest habits first.
List<PlannedReminder> planReminders(
  List<Habit> habits, {
  required bool enabled,
  required String body,
}) {
  if (!enabled) return const [];
  final plan = <PlannedReminder>[];
  for (final habit in habits) {
    if (!habit.notificationsEnabled) continue;
    final everyDay = habit.weekdays.length == 7;
    final days = everyDay
        ? const <int?>[null]
        : (habit.weekdays.toList()..sort());
    for (final time in habit.reminders) {
      for (final weekday in days) {
        if (plan.length == maxPlannedReminders) return plan;
        plan.add(
          PlannedReminder(
            id: plan.length + 1,
            habitId: habit.id,
            title: habit.name,
            body: body,
            time: time,
            weekday: weekday,
          ),
        );
      }
    }
  }
  return plan;
}
