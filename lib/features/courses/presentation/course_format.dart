import 'package:habit_builder/l10n/l10n.dart';

/// "2h 41m", "45m".
String formatCourseLength(AppLocalizations l10n, Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  return hours == 0
      ? l10n.durationMinutes(minutes)
      : l10n.durationHoursMinutes(hours, minutes);
}

/// "2:16".
String formatLessonLength(Duration duration) {
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${duration.inMinutes}:$seconds';
}
