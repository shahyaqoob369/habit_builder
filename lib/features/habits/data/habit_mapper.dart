import 'package:habit_builder/core/time/date_only.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

/// Converts habits to and from their Firestore documents at
/// `users/{uid}/habits/{habitId}` (see `firestore.rules`):
///
/// ```text
/// name, color, icon            strings ('orange', 'book', …)
/// createdAt                    'yyyy-MM-dd' (a calendar day)
/// sortKey                      int, creation time in ms (list order)
/// weekdays                     [1..7], Monday = 1
/// reminders                    ['HH:mm', …]
/// notificationsEnabled         bool
/// log                          {'yyyy-MM-dd': 'done' | 'missed'}
/// easiness                     {'yyyy-MM-dd': 1..10}
/// ```
///
/// Days are stored as calendar-day strings, so they don't move when the
/// user changes time zone. Unknown values from newer app versions fall
/// back to defaults instead of failing.
abstract final class HabitMapper {
  static Map<String, Object?> toFirestore(Habit habit, {int? sortKey}) => {
    'name': habit.name,
    'color': habit.color.name,
    'icon': habit.icon.name,
    'createdAt': dayKey(habit.createdAt),
    'sortKey': ?sortKey,
    'weekdays': habit.weekdays.toList()..sort(),
    'reminders': [for (final time in habit.reminders) time.toString()],
    'notificationsEnabled': habit.notificationsEnabled,
    'log': {
      for (final MapEntry(:key, :value) in habit.log.entries)
        dayKey(key): value.name,
    },
    'easiness': {
      for (final MapEntry(:key, :value) in habit.easiness.entries)
        dayKey(key): value,
    },
  };

  static Habit fromFirestore(String id, Map<String, Object?> data) {
    return Habit(
      id: id,
      name: data['name'] as String? ?? '',
      color: _byName(HabitColor.values, data['color'], HabitColor.orange),
      icon: _byName(HabitIcon.values, data['icon'], HabitIcon.book),
      createdAt: parseDay(data['createdAt']) ?? DateTime(2000),
      weekdays: {
        for (final day in data['weekdays'] as List<Object?>? ?? const [])
          if (day is int && day >= 1 && day <= 7) day,
      }.ifEmpty(Habit.allWeekdays),
      reminders: [
        for (final time in data['reminders'] as List<Object?>? ?? const [])
          ?_parseTime(time),
      ]..sort(),
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? false,
      log: {
        for (final MapEntry(:key, :value) in _map(data['log']).entries)
          ?parseDay(key): ?_statusByName[value],
      },
      easiness: {
        for (final MapEntry(:key, :value) in _map(data['easiness']).entries)
          if (parseDay(key) case final day?)
            if (value case final int score when score >= 1 && score <= 10)
              day: score,
      },
    );
  }

  /// 'yyyy-MM-dd' for [day]'s calendar day.
  static String dayKey(DateTime day) {
    final d = day.dateOnly;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-'
        '${two(d.day)}';
  }

  /// The calendar day of a 'yyyy-MM-dd' string, or null if it isn't one.
  static DateTime? parseDay(Object? value) {
    if (value is! String) return null;
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final [year, month, day] = [
      for (var i = 1; i <= 3; i++) int.parse(match.group(i)!),
    ];
    final date = DateTime(year, month, day);
    // Reject impossible dates such as 2026-02-31.
    return date.month == month && date.day == day ? date : null;
  }

  static final Map<Object?, DayStatus> _statusByName = {
    for (final status in DayStatus.values) status.name: status,
  };

  static Map<Object?, Object?> _map(Object? value) =>
      value is Map ? value : const {};

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
      values.where((v) => v.name == name).firstOrNull ?? fallback;

  static ReminderTime? _parseTime(Object? value) {
    if (value is! String) return null;
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return ReminderTime(hour, minute);
  }
}

extension on Set<int> {
  Set<int> ifEmpty(Set<int> fallback) => isEmpty ? fallback : this;
}
