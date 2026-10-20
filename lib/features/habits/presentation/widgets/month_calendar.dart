import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/chevron.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/widgets/habit_cell.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// Month calendar of a habit (Figma "Calendar"): month name between two
/// chevrons, weekday initials, then a 47 × 72 tile per day holding its
/// number and habit cell. Days of the neighbouring months are faded.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    required this.habit,
    required this.month,
    required this.color,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final Habit habit;

  /// Any day in the month to show.
  final DateTime month;

  final Color color;

  /// Null hides the arrow (no earlier / later month to show).
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  static const _tileHeight = 72.0;
  static const _rowGap = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final first = DateTime(month.year, month.month);
    final firstWeekday = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    // Days shown before the 1st, so that weeks start on firstWeekday.
    final lead = (first.weekday % 7 - firstWeekday) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final weeks = ((lead + daysInMonth) / 7).ceil();
    final days = [
      for (var i = 0; i < weeks * 7; i++)
        DateTime(first.year, first.month, 1 - lead + i),
    ];
    final weekday = DateFormat.E(locale);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 11, 5, 13),
        child: Column(
          children: [
            Row(
              children: [
                _Arrow(
                  direction: AxisDirection.left,
                  tooltip: l10n.calendarPrevious,
                  onTap: onPrevious,
                ),
                Expanded(
                  child: Text(
                    DateFormat.MMMM(locale).format(first),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle,
                  ),
                ),
                _Arrow(
                  direction: AxisDirection.right,
                  tooltip: l10n.calendarNext,
                  onTap: onNext,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Text(
                      weekday.format(days[i]).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.overline.copyWith(
                        color: colors.textMuted,
                        height: 14 / 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (var w = 0; w < weeks; w++)
              Padding(
                padding: EdgeInsets.only(top: w == 0 ? 0 : _rowGap),
                child: Row(
                  spacing: 6,
                  children: [
                    for (var d = 0; d < 7; d++)
                      Expanded(
                        child: _DayTile(
                          day: days[w * 7 + d],
                          inMonth: days[w * 7 + d].month == first.month,
                          habit: habit,
                          color: color,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.direction,
    required this.tooltip,
    required this.onTap,
  });

  final AxisDirection direction;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return SizedBox.square(
      dimension: 40,
      child: onTap == null
          ? null
          : IconButton(
              onPressed: onTap,
              tooltip: tooltip,
              icon: Chevron(
                color: context.colors.textPrimary,
                direction: direction,
              ),
            ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.inMonth,
    required this.habit,
    required this.color,
  });

  final DateTime day;
  final bool inMonth;
  final Habit habit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Opacity(
      opacity: inMonth ? 1 : 0.5,
      child: Container(
        height: MonthCalendar._tileHeight,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: AppRadii.card,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              '${day.day}',
              style: AppTextStyles.labelStrong.copyWith(
                color: inMonth
                    ? colors.textPrimary
                    : colors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            HabitCell(
              color: color,
              size: 38,
              status: inMonth ? habit.statusOn(day) : null,
            ),
          ],
        ),
      ),
    );
  }
}
