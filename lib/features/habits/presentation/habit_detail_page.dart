import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_builder/app/router/app_route.dart';
import 'package:habit_builder/app/theme/app_dimens.dart';
import 'package:habit_builder/app/theme/app_text_styles.dart';
import 'package:habit_builder/core/assets/app_icons.dart';
import 'package:habit_builder/core/extensions/build_context_x.dart';
import 'package:habit_builder/core/widgets/app_header.dart';
import 'package:habit_builder/core/widgets/header_icon_button.dart';
import 'package:habit_builder/core/widgets/primary_button.dart';
import 'package:habit_builder/core/widgets/state_views.dart';
import 'package:habit_builder/features/habits/application/habit_actions.dart';
import 'package:habit_builder/features/habits/application/habit_limit.dart';
import 'package:habit_builder/features/habits/application/habits_providers.dart';
import 'package:habit_builder/features/habits/domain/habit.dart';
import 'package:habit_builder/features/habits/domain/habit_stats.dart';
import 'package:habit_builder/features/habits/presentation/congratulation_dialog.dart';
import 'package:habit_builder/features/habits/presentation/habit_colors.dart';
import 'package:habit_builder/features/habits/presentation/reminder_format.dart';
import 'package:habit_builder/features/habits/presentation/sheets/easiness_sheet.dart';
import 'package:habit_builder/features/habits/presentation/widgets/frequency_card.dart';
import 'package:habit_builder/features/habits/presentation/widgets/habit_summary_card.dart';
import 'package:habit_builder/features/habits/presentation/widgets/month_calendar.dart';
import 'package:habit_builder/features/habits/presentation/widgets/stats_card.dart';
import 'package:habit_builder/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// Habit detail (Figma "Analytics"): summary, month calendar, the four
/// stats and the buttons to mark today complete or missed.
class HabitDetailPage extends ConsumerStatefulWidget {
  const HabitDetailPage({required this.habitId, super.key});

  final String habitId;

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  /// First day of the month shown in the calendar; null = this month.
  DateTime? _month;

  Future<void> _complete(Habit habit, DateTime today) async {
    final actions = ref.read(habitActionsProvider);
    final result = await actions.complete(
      habit,
      today,
      source: MarkSource.detail,
    );
    if (!mounted) return;
    final score = await showEasinessSheet(context);
    if (score != null) await actions.rate(result.habit, today, score);
    final milestone = result.milestone;
    if (milestone == null || !mounted) return;
    final choice = await showCongratulation(
      context,
      habitName: habit.name,
      streak: milestone,
    );
    if (choice == CongratulationChoice.createHabit && mounted) {
      openNewHabit(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final habits = ref.watch(habitsProvider);
    final today = ref.watch(todayProvider);
    final habit = habits.value
        ?.where((h) => h.id == widget.habitId)
        .firstOrNull;

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            title: habit?.name ?? '',
            leading: HeaderIconButton(
              icon: AppIcons.back,
              tooltip: l10n.backTooltip,
              onPressed: () => context.pop(),
            ),
            trailing: habit == null
                ? null
                : HeaderIconButton(
                    icon: AppIcons.edit,
                    tooltip: l10n.editHabitTitle,
                    onPressed: () => context.goNamed(
                      AppRoute.editHabit.name,
                      pathParameters: {'id': habit.id},
                    ),
                  ),
          ),
          Expanded(
            child: switch (habits) {
              AsyncValue(hasValue: true) when habit == null => MessageView(
                title: l10n.habitNotFoundTitle,
                body: l10n.habitNotFoundBody,
              ),
              AsyncValue(hasValue: true) => _Details(
                habit: habit!,
                today: today,
                month: _month ?? DateTime(today.year, today.month),
                onMonthChanged: (month) => setState(() => _month = month),
                onComplete: () => unawaited(_complete(habit, today)),
                onMiss: () => unawaited(
                  ref
                      .read(habitActionsProvider)
                      .miss(habit, today, source: MarkSource.detail),
                ),
              ),
              AsyncValue(hasError: true) => MessageView.error(
                context,
                onRetry: () => ref.invalidate(habitsProvider),
              ),
              _ => const LoadingView(),
            },
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.habit,
    required this.today,
    required this.month,
    required this.onMonthChanged,
    required this.onComplete,
    required this.onMiss,
  });

  final Habit habit;
  final DateTime today;
  final DateTime month;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onComplete;
  final VoidCallback onMiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final color = habit.color.resolve(colors);
    final stats = HabitStats.of(habit, today);
    final status = habit.statusOn(today);
    final created = DateTime(habit.createdAt.year, habit.createdAt.month);
    final thisMonth = DateTime(today.year, today.month);

    return ListView(
      padding: EdgeInsets.only(
        top: AppHeader.bottomGap + 1,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            children: [
              HabitSummaryCard(
                name: habit.name,
                color: color,
                repeat: _repeatText(context, habit),
                reminders: habit.reminders.isEmpty
                    ? l10n.habitNoReminders
                    : l10n.habitReminders(
                        habit.reminders
                            .map((t) => formatReminder(context, t))
                            .join(', '),
                      ),
              ),
              const SizedBox(height: 15),
              MonthCalendar(
                habit: habit,
                month: month,
                color: color,
                onPrevious: month.isAfter(created)
                    ? () => onMonthChanged(
                        DateTime(month.year, month.month - 1),
                      )
                    : null,
                onNext: month.isBefore(thisMonth)
                    ? () => onMonthChanged(
                        DateTime(month.year, month.month + 1),
                      )
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        // Figma: a soft band where the analytics section starts.
        Container(
          height: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors.backgroundDeep, colors.background],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.habitAnalytics,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionLabel.copyWith(
            color: colors.textMuted,
            height: 2,
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
          child: Column(
            children: [
              StatsCard(stats: stats),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: status == DayStatus.done
                    ? l10n.habitCompletedToday
                    : l10n.habitMarkComplete,
                onPressed: status == DayStatus.done ? null : onComplete,
              ),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: status == DayStatus.missed
                    ? l10n.habitMissedToday
                    : l10n.habitMarkMissed,
                tone: ButtonTone.surface,
                onPressed: status == DayStatus.missed ? null : onMiss,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _repeatText(BuildContext context, Habit habit) {
    final l10n = context.l10n;
    final preset = frequencyLabel(l10n, habit.weekdays);
    if (preset != l10n.frequencyCustom) return l10n.habitRepeat(preset);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = (habit.weekdays.toList()..sort())
        // 2026-10-19 is a Monday.
        .map((d) => DateFormat.E(locale).format(DateTime(2026, 10, 18 + d)))
        .join(', ');
    return l10n.habitRepeat(days);
  }
}
