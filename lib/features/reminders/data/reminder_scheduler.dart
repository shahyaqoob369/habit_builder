import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:habit_builder/features/reminders/domain/reminder_plan.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules habit reminders as local notifications on the device.
abstract interface class ReminderScheduler {
  /// Asks for permission to notify (once; later calls return the answer).
  Future<bool> requestPermission();

  /// Replaces every scheduled reminder with [plan].
  Future<void> schedule(List<PlannedReminder> plan);

  /// The habit of each reminder the user taps.
  Stream<String> get openedHabits;
}

/// Records what would be scheduled. The default, so tests never touch the
/// platform; `main` overrides it with [LocalReminderScheduler].
class RecordingReminderScheduler implements ReminderScheduler {
  RecordingReminderScheduler({this.permission = true});

  bool permission;
  List<PlannedReminder> scheduled = const [];
  final opened = StreamController<String>.broadcast();

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> schedule(List<PlannedReminder> plan) async => scheduled = plan;

  @override
  Stream<String> get openedHabits => opened.stream;
}

/// [ReminderScheduler] backed by flutter_local_notifications.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler({required this.channelName});

  /// Android's name for the reminders channel, shown in system settings.
  final String channelName;

  final _plugin = FlutterLocalNotificationsPlugin();
  final _opened = StreamController<String>.broadcast();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= () async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Object catch (error) {
      // Falls back to UTC; times would be off, but nothing crashes.
      debugPrint('Unknown time zone: $error');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        // Permission is asked when the user turns a reminder on.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final habitId = response.payload;
        if (habitId != null) _opened.add(habitId);
      },
    );
  }();

  @override
  Future<bool> requestPermission() async {
    await _init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> schedule(List<PlannedReminder> plan) async {
    await _init();
    await _plugin.cancelAll();
    final details = NotificationDetails(
      iOS: const DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'habit_reminders',
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    for (final reminder in plan) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        payload: reminder.habitId,
        scheduledDate: nextOccurrence(reminder, tz.TZDateTime.now(tz.local)),
        notificationDetails: details,
        // Inexact needs no special permission; a minute late is fine.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: reminder.weekday == null
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  @override
  Stream<String> get openedHabits => _opened.stream;

  /// The first time after [now] that [reminder] fires.
  @visibleForTesting
  static tz.TZDateTime nextOccurrence(
    PlannedReminder reminder,
    tz.TZDateTime now,
  ) {
    var next = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      reminder.time.hour,
      reminder.time.minute,
    );
    while (!next.isAfter(now) ||
        (reminder.weekday != null && next.weekday != reminder.weekday)) {
      next = tz.TZDateTime(
        now.location,
        next.year,
        next.month,
        next.day + 1,
        reminder.time.hour,
        reminder.time.minute,
      );
    }
    return next;
  }
}

/// The app's [ReminderScheduler].
final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => RecordingReminderScheduler(),
);
