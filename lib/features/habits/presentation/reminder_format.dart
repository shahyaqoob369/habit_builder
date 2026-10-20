import 'package:flutter/widgets.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:intl/intl.dart';

/// Formats a reminder like the design: "06:00 AM", or "10:00AM" when
/// [compact].
String formatReminder(
  BuildContext context,
  ReminderTime time, {
  bool compact = false,
}) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final text = DateFormat(compact ? 'hh:mma' : 'hh:mm a', locale).format(
    DateTime(2000, 1, 1, time.hour, time.minute),
  );
  return text;
}
