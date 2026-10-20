// Schedules reminders with the real iOS / Android notification system:
//   flutter test integration_test/reminders_test.dart -d <device id>
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/reminders/data/reminder_scheduler.dart';
import 'package:habit_builder/features/reminders/domain/reminder_plan.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('schedules, replaces and cancels reminders', (tester) async {
    final scheduler = LocalReminderScheduler(channelName: 'Habit reminders');
    final plan = planReminders(
      [
        Habit(
          id: 'read',
          name: 'Read',
          color: HabitColor.orange,
          createdAt: DateTime(2026, 10),
          reminders: const [ReminderTime(7, 30)],
          notificationsEnabled: true,
        ),
        Habit(
          id: 'run',
          name: 'Run',
          color: HabitColor.red,
          createdAt: DateTime(2026, 10),
          weekdays: const {1, 3},
          reminders: const [ReminderTime(18, 0)],
          notificationsEnabled: true,
        ),
      ],
      enabled: true,
      body: 'Time for your habit.',
    );
    final plugin = FlutterLocalNotificationsPlugin();
    // Initializes the plugin.
    await scheduler.schedule(const []);
    // iOS drops reminders the app may not show. Provisional (quiet)
    // permission is granted without a dialog, which a test can't tap;
    // it needs the alert and sound options too.
    await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true, provisional: true);

    await scheduler.schedule(plan);
    var pending = await plugin.pendingNotificationRequests();
    expect(pending.map((p) => p.id).toSet(), {1, 2, 3});
    expect(pending.map((p) => p.title).toSet(), {'Read', 'Run'});
    expect(pending.map((p) => p.payload).toSet(), {'read', 'run'});

    // A new plan replaces the old one.
    await scheduler.schedule(plan.take(1).toList());
    pending = await plugin.pendingNotificationRequests();
    expect(pending.single.title, 'Read');

    await scheduler.schedule(const []);
    expect(await plugin.pendingNotificationRequests(), isEmpty);
  });
}
