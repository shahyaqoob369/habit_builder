import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/time/date_only.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/habit_colors.dart';
import 'package:habit_builder/features/habits/presentation/widgets/habit_cell.dart';
import 'package:habit_builder/features/home/presentation/widgets/day_chip.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// The Home tracking grid (Figma "Body"): the "HABITS" column with one white
/// row per habit, and the day columns (week strip + cells) that scroll
/// sideways together, today on the right.
class HabitGrid extends StatelessWidget {
  const HabitGrid({
    required this.habits,
    required this.days,
    required this.today,
    required this.onCellTap,
    required this.onHabitTap,
    super.key,
  });

  final List<Habit> habits;

  /// The days to show, oldest first; the last one is [today].
  final List<DateTime> days;
  final DateTime today;

  final void Function(Habit habit, DateTime day) onCellTap;
  final ValueChanged<Habit> onHabitTap;

  // Figma geometry: label column 117 pt (x 20–137), hairline, day columns
  // every 56 pt starting 15 pt after it; strip 50 pt, 13 pt gap, then 70 pt
  // rows 8 pt apart.
  static const labelWidth = 117.0;
  static const columnWidth = 56.0;
  static const stripHeight = 50.0;
  static const stripGap = 13.0;
  static const rowHeight = 70.0;
  static const rowGap = 8.0;
  static const _daysStart = 15.0;
  static const _daysEnd = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekday = DateFormat.E(locale);

    return Stack(
      children: [
        // White row backgrounds, running off the right edge like the design.
        Column(
          children: [
            const SizedBox(height: stripHeight + stripGap),
            for (final _ in habits)
              Container(
                height: rowHeight,
                margin: const EdgeInsets.only(
                  left: AppSpacing.screen,
                  bottom: rowGap,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: labelWidth),
                child: VerticalDivider(width: 1, color: colors.divider),
              ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: AppSpacing.screen + labelWidth + 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: stripHeight,
                    child: _Label(context.l10n.homeHabitsLabel.toUpperCase()),
                  ),
                  const SizedBox(height: stripGap),
                  for (final habit in habits)
                    _HabitName(habit: habit, onTap: () => onHabitTap(habit)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Starts at the newest day.
                reverse: true,
                padding: const EdgeInsets.only(
                  left: _daysStart - (columnWidth - DayChip.size) / 2,
                  right: _daysEnd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (final day in days)
                          SizedBox(
                            width: columnWidth,
                            child: Center(
                              child: DayChip(
                                weekday: weekday.format(day),
                                date: day.day,
                                isToday: day.isSameDay(today),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: stripGap),
                    for (final habit in habits)
                      Padding(
                        padding: const EdgeInsets.only(bottom: rowGap),
                        child: SizedBox(
                          height: rowHeight,
                          child: Row(
                            children: [
                              for (final day in days)
                                _DayCell(
                                  habit: habit,
                                  day: day,
                                  onTap: () => onCellTap(habit, day),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.screen + 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppTextStyles.rowLabel),
      ),
    );
  }
}

class _HabitName extends StatelessWidget {
  const _HabitName({required this.habit, required this.onTap});

  final Habit habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.screen,
        bottom: HabitGrid.rowGap,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
        child: SizedBox(
          height: HabitGrid.rowHeight,
          width: HabitGrid.labelWidth,
          child: Padding(
            padding: const EdgeInsets.only(left: 18, right: AppSpacing.xs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                habit.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.rowLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.habit, required this.day, required this.onTap});

  final Habit habit;
  final DateTime day;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = habit.statusOn(day);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.MMMEd(locale).format(day);
    final label = switch (status) {
      DayStatus.done => l10n.dayStatusDone,
      DayStatus.missed => l10n.dayStatusMissed,
      null => l10n.dayStatusNone,
    };
    return Semantics(
      button: true,
      label: '${habit.name}, $date, $label',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        // Unmarked days draw nothing but must still take taps.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: HabitGrid.columnWidth,
          height: HabitGrid.rowHeight,
          child: Center(
            child: HabitCell(
              color: habit.color.resolve(context.colors),
              status: status,
              showEmpty: false,
            ),
          ),
        ),
      ),
    );
  }
}
