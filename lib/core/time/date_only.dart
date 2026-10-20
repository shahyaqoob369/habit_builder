/// Calendar-day helpers. Habit history is keyed by local calendar day.
extension DateOnly on DateTime {
  /// This moment's local calendar day, at midnight.
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}
