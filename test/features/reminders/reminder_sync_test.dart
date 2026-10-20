import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/core/storage/preferences.dart';
import 'package:habit_builder/features/habits/data/fake_habit_repository.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/reminders/application/reminder_sync.dart';
import 'package:habit_builder/features/reminders/data/reminder_scheduler.dart';
import 'package:habit_builder/features/reminders/domain/reminder_plan.dart';
import 'package:habit_builder/features/settings/data/settings_repository.dart';

import '../../helpers/test_preferences.dart';

class _CountingScheduler extends RecordingReminderScheduler {
  int calls = 0;

  @override
  Future<void> schedule(List<PlannedReminder> plan) {
    calls++;
    return super.schedule(plan);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reminderSyncProvider', () {
    late _CountingScheduler scheduler;
    late FakeHabitRepository habits;
    late ProviderContainer container;

    setUp(() async {
      scheduler = _CountingScheduler();
      habits = FakeHabitRepository(
        habits: [
          Habit(
            id: 'read',
            name: 'Read',
            color: HabitColor.orange,
            createdAt: DateTime(2026, 10),
            reminders: const [ReminderTime(8, 0)],
            notificationsEnabled: true,
          ),
        ],
      );
      container = ProviderContainer.test(
        overrides: [
          reminderSchedulerProvider.overrideWithValue(scheduler),
          habitRepositoryProvider.overrideWithValue(habits),
          sharedPreferencesProvider.overrideWithValue(
            await createTestPreferences(),
          ),
        ],
      )..listen(reminderSyncProvider, (_, _) {});
      // Let the habits stream deliver.
      await pumpEventQueue();
    });

    test('schedules the reminders of the habits', () {
      expect(scheduler.scheduled.single.title, 'Read');
    });

    test('marking a day does not reschedule', () async {
      final before = scheduler.calls;
      await habits.setStatus('read', DateTime(2026, 10, 20), DayStatus.done);
      await pumpEventQueue();

      expect(scheduler.calls, before);
    });

    test('the Settings switch cancels and restores them', () async {
      final settings = container.read(settingsProvider.notifier);

      await settings.setHabitReminders(enabled: false);
      await pumpEventQueue();
      expect(scheduler.scheduled, isEmpty);

      await settings.setHabitReminders(enabled: true);
      await pumpEventQueue();
      expect(scheduler.scheduled, hasLength(1));
    });

    test('deleting the habit cancels its reminder', () async {
      await habits.deleteHabit('read');
      await pumpEventQueue();

      expect(scheduler.scheduled, isEmpty);
    });

    test('coming back to the app schedules again', () async {
      final before = scheduler.calls;
      TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.inactive,
      );
      TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      );
      await pumpEventQueue();

      expect(scheduler.calls, before + 1);
    });
  });
}
