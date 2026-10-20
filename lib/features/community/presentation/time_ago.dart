import 'package:flutter/widgets.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// "just now", "41m ago", "3h ago", "2d ago", then the date.
String formatTimeAgo(BuildContext context, DateTime time, DateTime now) {
  final l10n = context.l10n;
  final elapsed = now.difference(time);
  if (elapsed.inMinutes < 1) return l10n.timeJustNow;
  if (elapsed.inHours < 1) return l10n.timeMinutesAgo(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.timeHoursAgo(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.timeDaysAgo(elapsed.inDays);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.MMMd(locale).format(time);
}

/// "3.1k".
String formatCount(BuildContext context, int count) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat.compact(locale: locale).format(count).toLowerCase();
}
