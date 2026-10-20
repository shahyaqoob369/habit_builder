import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';

/// The user's habits, kept up to date.
final StreamProvider<List<Habit>> habitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(habitRepositoryProvider).watchHabits(),
);

/// Today's date (midnight). Overridden in tests.
final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
