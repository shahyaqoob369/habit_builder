import 'package:flutter/foundation.dart';
import 'package:habit_builder/core/time/date_only.dart';

/// The four habit colors of the design.
enum HabitColor { orange, red, blue, magenta }

/// Icons a habit can have (not designed beyond the book: a fixed free set,
/// owner question Q5).
enum HabitIcon {
  book,
  run,
  workout,
  walk,
  bike,
  swim,
  sleep,
  wakeUp,
  water,
  fruit,
  veggies,
  meds,
  teeth,
  relax,
  pray,
  learn,
  write,
  language,
  music,
  dog,
  plants,
  clean,
  save,
  quit,
}

/// How a day went for a habit. A day with no entry is "not marked".
///
/// The design draws [done] as a full cell and [missed] as a half cell.
enum DayStatus {
  done,
  missed
  ;

  /// The status after tapping a cell: not marked → done → missed → not
  /// marked.
  static DayStatus? cycle(DayStatus? current) => switch (current) {
    null => done,
    done => missed,
    missed => null,
  };
}

/// A reminder time, independent of Flutter's `TimeOfDay`.
@immutable
class ReminderTime implements Comparable<ReminderTime> {
  const ReminderTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour must be 0–23'),
      assert(minute >= 0 && minute < 60, 'minute must be 0–59');

  final int hour;
  final int minute;

  @override
  int compareTo(ReminderTime other) =>
      (hour * 60 + minute).compareTo(other.hour * 60 + other.minute);

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

/// A habit the user tracks.
@immutable
class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.icon = HabitIcon.book,
    this.weekdays = allWeekdays,
    this.reminders = const [],
    this.notificationsEnabled = false,
    this.log = const {},
  });

  /// Every day of the week, as [DateTime.weekday] values (Monday = 1).
  static const allWeekdays = {1, 2, 3, 4, 5, 6, 7};

  final String id;
  final String name;
  final HabitColor color;
  final DateTime createdAt;
  final HabitIcon icon;

  /// Days of the week the habit is due ([DateTime.weekday] values).
  final Set<int> weekdays;

  final List<ReminderTime> reminders;
  final bool notificationsEnabled;

  /// Marked days, keyed by calendar day (see [DateOnly.dateOnly]).
  final Map<DateTime, DayStatus> log;

  DayStatus? statusOn(DateTime day) => log[day.dateOnly];

  bool isDueOn(DateTime day) => weekdays.contains(day.weekday);

  Habit copyWith({
    String? name,
    HabitColor? color,
    HabitIcon? icon,
    Set<int>? weekdays,
    List<ReminderTime>? reminders,
    bool? notificationsEnabled,
    Map<DateTime, DayStatus>? log,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
      icon: icon ?? this.icon,
      weekdays: weekdays ?? this.weekdays,
      reminders: reminders ?? this.reminders,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      log: log ?? this.log,
    );
  }

  /// A copy with [day] marked as [status], or unmarked when it is null.
  Habit withStatus(DateTime day, DayStatus? status) {
    final key = day.dateOnly;
    final next = Map<DateTime, DayStatus>.of(log);
    if (status == null) {
      next.remove(key);
    } else {
      next[key] = status;
    }
    return copyWith(log: Map.unmodifiable(next));
  }
}
