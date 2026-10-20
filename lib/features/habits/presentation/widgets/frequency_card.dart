import 'package:flutter/material.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/presentation/widgets/form_row.dart';
import 'package:habit_builder/features/habits/presentation/widgets/habit_cell.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// "Habit Frequency" card (Figma "Frequency"): the preset on the right, then
/// the seven days of the week; a due day is a full cell, a day off a half
/// one. Tapping a day turns it on or off.
class FrequencyCard extends StatelessWidget {
  const FrequencyCard({
    required this.weekdays,
    required this.color,
    required this.onDayTap,
    required this.onPresetTap,
    super.key,
  });

  final Set<int> weekdays;
  final Color color;
  final ValueChanged<int> onDayTap;
  final VoidCallback onPresetTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final localizations = MaterialLocalizations.of(context);
    final first = localizations.firstDayOfWeekIndex; // 0 = Sunday
    // DateTime.weekday values in display order (Sunday = 7).
    final order = [for (var i = 0; i < 7; i++) (first + i - 1) % 7 + 1];
    final locale = Localizations.localeOf(context).toLanguageTag();
    final shortName = DateFormat.E(locale);
    final longName = DateFormat.EEEE(locale);
    // 2026-10-19 is a Monday: weekday n is that date + (n - 1) days.
    DateTime dayOf(int weekday) => DateTime(2026, 10, 18 + weekday);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.card,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onPresetTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.newHabitFrequency,
                        style: AppTextStyles.body,
                      ),
                    ),
                    ValueChevron(value: frequencyLabel(l10n, weekdays)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          IntrinsicHeight(
            child: Row(
              children: [
                for (final (i, weekday) in order.indexed) ...[
                  if (i > 0) VerticalDivider(width: 1, color: colors.divider),
                  Expanded(
                    child: Semantics(
                      button: true,
                      toggled: weekdays.contains(weekday),
                      label: longName.format(dayOf(weekday)),
                      excludeSemantics: true,
                      onTap: () => onDayTap(weekday),
                      child: InkWell(
                        onTap: () => onDayTap(weekday),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 14),
                          child: Column(
                            children: [
                              Text(
                                shortName.format(dayOf(weekday)).toUpperCase(),
                                style: AppTextStyles.overline.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              HabitCell(
                                color: color,
                                size: 38,
                                status: weekdays.contains(weekday)
                                    ? DayStatus.done
                                    : DayStatus.missed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The preset name for [weekdays]: "Every day", "Weekdays", "Weekends" or
/// "Custom".
String frequencyLabel(AppLocalizations l10n, Set<int> weekdays) {
  bool same(Set<int> other) =>
      weekdays.length == other.length && weekdays.containsAll(other);
  if (same(Habit.allWeekdays)) return l10n.frequencyEveryDay;
  if (same(FrequencyPreset.weekdays.days)) return l10n.frequencyWeekdays;
  if (same(FrequencyPreset.weekends.days)) return l10n.frequencyWeekends;
  return l10n.frequencyCustom;
}

/// Quick choices for the frequency (not in the design).
enum FrequencyPreset {
  everyDay(Habit.allWeekdays),
  weekdays({1, 2, 3, 4, 5}),
  weekends({6, 7})
  ;

  const FrequencyPreset(this.days);

  final Set<int> days;

  String label(AppLocalizations l10n) => switch (this) {
    everyDay => l10n.frequencyEveryDay,
    weekdays => l10n.frequencyWeekdays,
    weekends => l10n.frequencyWeekends,
  };
}
