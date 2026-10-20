import 'package:habit_builder/features/habits/domain/habit.dart';

/// Where habits are stored. The UI talks only to this interface: a fake
/// in-memory implementation for now, Firestore from plan step 18.
abstract interface class HabitRepository {
  /// The user's habits, oldest first, re-emitted on every change.
  Stream<List<Habit>> watchHabits();

  Future<Habit> addHabit(Habit habit);

  Future<void> updateHabit(Habit habit);

  Future<void> deleteHabit(String id);

  /// Marks [day] of habit [id] as [status], or clears it when null.
  Future<void> setStatus(String id, DateTime day, DayStatus? status);
}
