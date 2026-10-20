import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/app/router/app_router.dart';
import 'package:habit_builder/core/links/link_launcher.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/reminders/data/reminder_scheduler.dart';
import 'package:habit_builder/features/reminders/domain/reminder_plan.dart';
import 'package:habit_builder/features/settings/data/settings_repository.dart';
import 'package:habit_builder/l10n/l10n.dart';

/// Keeps the scheduled reminders in step with the habits and the Settings
/// switch, and opens a habit when its reminder is tapped. `App` keeps it
/// alive. Signing out empties the habits, which cancels every reminder.
final Provider<void> reminderSyncProvider = Provider<void>((ref) {
  final scheduler = ref.watch(reminderSchedulerProvider);
  final body = deviceLocalizations().reminderBody;
  List<PlannedReminder>? scheduled;

  void sync({bool force = false}) {
    final habits = ref.read(habitsProvider).value;
    if (habits == null) return;
    final plan = planReminders(
      habits,
      enabled: ref.read(settingsProvider).habitReminders,
      body: body,
    );
    // Marking days changes the habits but not the plan.
    if (!force && listEquals(plan, scheduled)) return;
    scheduled = plan;
    unawaited(scheduler.schedule(plan));
  }

  ref
    ..listen(habitsProvider, (_, _) => sync(), fireImmediately: true)
    ..listen(
      settingsProvider.select((settings) => settings.habitReminders),
      (_, _) => sync(),
    );

  // Back in the app: notifications may have been allowed in iOS Settings
  // since (iOS drops reminders scheduled without permission), and the
  // time zone may have changed. Schedule again.
  final lifecycle = AppLifecycleListener(onResume: () => sync(force: true));
  ref.onDispose(lifecycle.dispose);

  final opened = scheduler.openedHabits.listen(
    (habitId) => ref
        .read(appRouterProvider)
        .goNamed(AppRoute.habitDetail.name, pathParameters: {'id': habitId}),
  );
  ref.onDispose(opened.cancel);
});

/// Strings in the device's language, for text shown outside a widget
/// (notifications). English when the language isn't supported.
AppLocalizations deviceLocalizations() {
  final language = PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.any(
    (locale) => locale.languageCode == language,
  );
  return lookupAppLocalizations(Locale(supported ? language : 'en'));
}

/// Asks for notification permission before a reminder is turned on. If
/// the user said no before, explains where to turn it on. Returns whether
/// reminders can be shown.
Future<bool> ensureReminderPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final granted = await ref.read(reminderSchedulerProvider).requestPermission();
  if (!granted) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.remindersDenied),
          action: SnackBarAction(
            label: l10n.remindersOpenSettings,
            onPressed: () => unawaited(
              ref.read(openLinkProvider)(Uri.parse('app-settings:')),
            ),
          ),
        ),
      );
  }
  return granted;
}
