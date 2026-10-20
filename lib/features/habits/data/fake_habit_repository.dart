import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/core/time/date_only.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_repository.dart';

/// In-memory [HabitRepository], seeded with the design's four sample habits
/// and a few days of history ending today. Used until Firestore (plan
/// step 18); changes last until the app restarts.
class FakeHabitRepository implements HabitRepository {
  /// Starts with [habits], or the design's samples when null.
  FakeHabitRepository({DateTime? today, bool seed = true, List<Habit>? habits})
    : _habits =
          habits ??
          (seed ? _sampleHabits((today ?? DateTime.now()).dateOnly) : []);

  List<Habit> _habits;

  /// The current habits, for tests: awaiting [watchHabits] inside a widget
  /// test's fake clock never completes.
  @visibleForTesting
  List<Habit> get habits => _habits;
  final _changes = StreamController<List<Habit>>.broadcast();
  var _nextId = 100;

  @override
  Stream<List<Habit>> watchHabits() {
    // Subscribe to changes as soon as someone listens, so nothing between
    // the current list and the next change is lost.
    StreamSubscription<List<Habit>>? changes;
    late final StreamController<List<Habit>> controller;
    controller = StreamController<List<Habit>>(
      onListen: () {
        controller.add(_habits);
        changes = _changes.stream.listen(controller.add);
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Habit> addHabit(Habit habit) async {
    final added = Habit(
      id: 'habit-${_nextId++}',
      name: habit.name,
      color: habit.color,
      createdAt: habit.createdAt,
      icon: habit.icon,
      weekdays: habit.weekdays,
      reminders: habit.reminders,
      notificationsEnabled: habit.notificationsEnabled,
      log: habit.log,
      easiness: habit.easiness,
    );
    _emit([..._habits, added]);
    return added;
  }

  @override
  Future<void> updateHabit(Habit habit) async =>
      _emit([for (final h in _habits) h.id == habit.id ? habit : h]);

  @override
  Future<void> deleteHabit(String id) async => _emit([
    for (final h in _habits)
      if (h.id != id) h,
  ]);

  @override
  Future<void> setStatus(String id, DateTime day, DayStatus? status) async =>
      _emit([
        for (final h in _habits) h.id == id ? h.withStatus(day, status) : h,
      ]);

  void _emit(List<Habit> habits) {
    _habits = List.unmodifiable(habits);
    _changes.add(_habits);
  }

  /// The design's habits ("Homepage – Tracking Habits") with its pattern
  /// of done (full) and missed (half) cells over the five days ending
  /// [today]; null is an unmarked day.
  static List<Habit> _sampleHabits(DateTime today) {
    final start = today.subtract(const Duration(days: 4));
    Habit sample(
      String id,
      String name,
      HabitColor color,
      HabitIcon icon,
      List<DayStatus?> days,
    ) {
      return Habit(
        id: id,
        name: name,
        color: color,
        icon: icon,
        createdAt: start.subtract(const Duration(days: 30)),
        reminders: const [ReminderTime(10, 0)],
        log: {
          for (var i = 0; i < days.length; i++)
            start.add(Duration(days: i)): ?days[i],
        },
      );
    }

    const done = DayStatus.done;
    const missed = DayStatus.missed;
    return List.unmodifiable([
      sample('read', 'Read A Book', HabitColor.orange, HabitIcon.book, [
        done, done, missed, done, done, //
      ]),
      sample('exercise', 'Exercise', HabitColor.red, HabitIcon.workout, [
        done, done, missed, done, null, //
      ]),
      sample('wake', 'Wake Up Early', HabitColor.blue, HabitIcon.wakeUp, [
        done, missed, done, null, null, //
      ]),
      sample('walk', 'Walk Dog', HabitColor.magenta, HabitIcon.dog, [
        done, missed, done, missed, null, //
      ]),
    ]);
  }
}

/// The app's [HabitRepository].
final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => FakeHabitRepository(),
);
